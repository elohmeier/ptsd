{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.wireguard;
  enabledNetworks = filterAttrs (_: v: v.enable) cfg.networks;
  natForwardNetworks = filterAttrs (_: v: v.natForwardIf != "") enabledNetworks;
  reresolveDnsNetworks = filterAttrs (_: v: v.client.reresolveDns) enabledNetworks;
  universe = import ../2configs/universe.nix;

  generateSecret = _: netcfg: nameValuePair
    netcfg.keyname
    {
      owner = "systemd-network";
      mode = "0440";
      dependants = [ "systemd-networkd.service" ];
    };

  vpnPeers = netname: filterAttrs (hostname: hostcfg: hostname != config.networking.hostName && hasAttrByPath [ "nets" netname ] hostcfg) universe.hosts;

  generateWireguardPeers = netname: netcfg:
    if netcfg.server.enable then
      (
        map
          (
            h: {
              wireguardPeerConfig = {
                PublicKey = h.nets."${netname}".wireguard.pubkey;
                AllowedIPs = [ "${h.nets."${netname}".ip4.addr}/32" ] ++ (if builtins.hasAttr "networks" h.nets."${netname}".wireguard then h.nets."${netname}".wireguard.networks else [ ]);
              };
            }
          )
          (builtins.attrValues (vpnPeers netname))
      )
    else
      [
        {
          wireguardPeerConfig = {
            PublicKey = netcfg.publicKey;
            AllowedIPs = netcfg.client.allowedIPs;
            Endpoint = netcfg.client.endpoint;
            PersistentKeepalive = netcfg.persistentKeepalive;
          };
        }
      ];

  generateNetdev = netname: netcfg: nameValuePair
    "10-${netcfg.ifname}"
    {
      netdevConfig = {
        Name = "${netcfg.ifname}";
        Kind = "wireguard";
        MTUBytes = "1300";
      };

      wireguardConfig = {
        PrivateKeyFile = mkIf config.ptsd.secrets.enable config.ptsd.secrets.files."${netcfg.keyname}".path;
      } // optionalAttrs netcfg.server.enable {
        ListenPort = netcfg.server.listenPort;
      };

      wireguardPeers = generateWireguardPeers netname netcfg;
    };

  generateNetwork = _: netcfg:
    nameValuePair
      "20-${netcfg.ifname}"
      {
        matchConfig = {
          Name = "${netcfg.ifname}";
        };
        address = [
          "${netcfg.ip}/${toString netcfg.subnetMask}"
        ];
        routes = netcfg.routes;
      } // optionalAttrs netcfg.server.enable {
      networkConfig = {
        IPForward = "ipv4";
        IPMasquerade = "yes";
      };
    };

  generateHosts = netname:
    listToAttrs
      (
        map
          (h:
            nameValuePair h.nets."${netname}".ip4.addr h.nets."${netname}".aliases
          )
          (builtins.attrValues (
            filterAttrs (hostname: hostcfg: hasAttrByPath [ "nets" netname "aliases" ] hostcfg)
              (vpnPeers netname)
          ))
      );

  # network interface ordering has no effect, that's why we call them "A" and "B"
  genNatForward = ifA: ifB: op: ''
    ### ptsd.wireguard: configure NAT forwarding in both directions of a network interface pair ###
    
    # continue forwarding of established or related connections
    iptables -${op} FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # forward A -> B
    iptables -t nat -${op} POSTROUTING -o ${ifB} -j MASQUERADE
    iptables -${op} FORWARD -i ${ifA} -o ${ifB} -j ACCEPT

    # forward B -> A
    iptables -t nat -${op} POSTROUTING -o ${ifA} -j MASQUERADE
    iptables -${op} FORWARD -i ${ifB} -o ${ifA} -j ACCEPT
  '';

  genNatForwardUp = ifA: ifB: (genNatForward ifA ifB "A");
  genNatForwardDown = ifA: ifB: (genNatForward ifA ifB "D");

  generateReresolveDnsUnit = netname: netcfg:
    let
      wireguardPeers = generateWireguardPeers netname netcfg;
      peersWithEndpoint = filter (peer: hasAttrByPath [ "wireguardPeerConfig" "Endpoint" ] peer) wireguardPeers;
    in
    nameValuePair "wireguard-${netname}-reresolve" {
      description = "Reresolve WireGuard Tunnel - ${netname}";
      requires = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      path = with pkgs; [ wireguard-tools ];

      # from https://git.zx2c4.com/WireGuard/tree/contrib/examples/reresolve-dns/reresolve-dns.sh
      script = ''
        INTERFACE="${netname}"

        reset_peer_section() {
          PUBLIC_KEY=""
          ENDPOINT=""
        }

        process_peer() {
          [[ -z $PUBLIC_KEY || -z $ENDPOINT ]] && return 0
          [[ $(wg show "$INTERFACE" latest-handshakes) =~ ''${PUBLIC_KEY//+/\\+}\${"\t"}([0-9]+) ]] || return 0
          (( ($(date +%s) - ''${BASH_REMATCH[1]}) > 135 )) || return 0
          wg set "$INTERFACE" peer "$PUBLIC_KEY" endpoint "$ENDPOINT"
          echo reloaded endpoint for peer $PUBLIC_KEY
          reset_peer_section
        }

        ${concatMapStringsSep "\n"
          (
          peer: ''
              PUBLIC_KEY="${peer.wireguardPeerConfig.PublicKey}"
              ENDPOINT="${peer.wireguardPeerConfig.Endpoint}"
              process_peer;
            ''
          )
          peersWithEndpoint}
      '';

      startAt = "minutely";
    };

  generateSysctlForward = _: netcfg: nameValuePair
    "net.ipv4.conf.${netcfg.ifname}.forwarding"
    true;
in
{
  # TODO: support https://www.jordanwhited.com/posts/wireguard-endpoint-discovery-nat-traversal/

  options = {
    ptsd.wireguard = {
      enableGlobalForwarding = mkOption
        {
          description = ''
            configures IP forwarding e.g. for routing packets
          '';
          type = types.bool;
          default = false;
        };
      networks = mkOption {
        type = types.attrsOf (
          types.submodule (
            { config, ... }: {
              options = {
                ifname = mkOption {
                  type = types.str;
                  default = config._module.args.name;
                };
                enable = mkEnableOption "${config.ifname}";
                ip = mkOption {
                  type = types.str;
                  example = "191.18.19.123";
                };
                subnetMask = mkOption {
                  type = types.int;
                  default = 24;
                  description = "CIDR notation";
                };
                publicKey = mkOption {
                  type = types.str;
                };
                persistentKeepalive = mkOption {
                  type = types.int;
                  default = 21;
                };
                keyname = mkOption {
                  type = types.str;
                  default = "${config.ifname}.key";
                };
                client = mkOption {
                  type = types.submodule {
                    options = {
                      endpoint = mkOption {
                        type = types.str;
                      };
                      reresolveDns = mkOption {
                        type = types.bool;
                        default = false;
                      };
                      allowedIPs = mkOption {
                        type = with types; listOf str;
                      };
                    };
                  };
                  default = { };
                };
                server = mkOption {
                  type = types.submodule {
                    options = {
                      enable = mkEnableOption "${config.ifname}-server";
                      listenPort = mkOption {
                        type = types.int;
                      };
                    };
                  };
                  default = { };
                };
                natForwardIf = mkOption {
                  description = ''
                    if set to a network interface name, NAT rules will be set
                    up to forward traffic (in both directions), e.g. to make
                    remote networks accessible from the VPN.
                  '';
                  example = "eth0";
                  default = "";
                };
                routes = mkOption {
                  description = ''
                    systemd-networkd route configuration to apply to the network interface.
                  '';
                  type = types.listOf types.attrs;
                  default = [ ];
                  example = [
                    { routeConfig = { Destination = "192.168.178.0/24"; }; }
                  ];
                };
              };
            }
          )
        );
        default = { };
      };
    };
  };

  config = mkIf (enabledNetworks != { }) {
    assertions =
      [
        {
          assertion = config.networking.useNetworkd;
          message = "ptsd.wireguard only supports systemd-networkd.";
        }
      ];

    environment.systemPackages = [ pkgs.wireguard ];
    boot.extraModulePackages = lib.optional (lib.versionOlder config.boot.kernelPackages.kernel.version "5.6") config.boot.kernelPackages.wireguard;

    ptsd.secrets.files = mapAttrs' generateSecret enabledNetworks;

    users.groups.keys.members = [ "systemd-network" ];

    systemd.network = {
      netdevs = mapAttrs' generateNetdev enabledNetworks;
      networks = mapAttrs' generateNetwork enabledNetworks;
    };

    networking.firewall = {
      allowedUDPPorts = mapAttrsToList (_: v: v.server.listenPort) (filterAttrs (_: v: v.server.enable) enabledNetworks);
    } // optionalAttrs (natForwardNetworks != { }) {
      extraCommands = concatStringsSep "\n" (mapAttrsToList (_: netcfg: (genNatForwardUp netcfg.ifname netcfg.natForwardIf)) natForwardNetworks);
      extraStopCommands = concatStringsSep "\n" (mapAttrsToList (_: netcfg: (genNatForwardDown netcfg.ifname netcfg.natForwardIf)) natForwardNetworks);
    };

    networking.hosts = mapAttrs (name: value: flatten value) (zipAttrs (map (netname: generateHosts netname) (attrNames enabledNetworks)));

    boot.kernel.sysctl =
      optionalAttrs cfg.enableGlobalForwarding
        {
          "net.ipv4.conf.all.forwarding" = true;
          "net.ipv4.conf.default.forwarding" = true;
        } // (mapAttrs' generateSysctlForward (filterAttrs (_: v: v.server.enable) enabledNetworks));

    systemd.services = mapAttrs' generateReresolveDnsUnit reresolveDnsNetworks;
  };
}
