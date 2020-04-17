{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.wireguard;
  enabledNetworks = filterAttrs (_: v: v.enable) cfg.networks;
  natForwardNetworks = filterAttrs (_: v: v.natForwardIf != "") enabledNetworks;
  universe = import <ptsd/2configs/universe.nix>;

  generateSecret = _: netcfg: nameValuePair
    netcfg.keyname {
    owner = "systemd-network";
    mode = "0440";
    dependants = [ "systemd-networkd.service" ];
  };

  vpnClients = netname: filterAttrs (hostname: hostcfg: hostname != config.networking.hostName && hasAttrByPath [ "nets" netname ] hostcfg) universe.hosts;

  generateNetdev = netname: netcfg: nameValuePair
    "10-${netcfg.ifname}" {
    netdevConfig = {
      Name = "${netcfg.ifname}";
      Kind = "wireguard";
      MTUBytes = "1300";
    };

    wireguardConfig = {
      PrivateKeyFile = config.ptsd.secrets.files."${netcfg.keyname}".path;
    } // optionalAttrs netcfg.server.enable {
      ListenPort = netcfg.server.listenPort;
    };

    wireguardPeers =
      if netcfg.server.enable then (
        map (
          h: {
            wireguardPeerConfig = {
              PublicKey = h.nets.nwvpn.wireguard.pubkey;
              AllowedIPs = [ "${h.nets.nwvpn.ip4.addr}/32" ] ++ (if builtins.hasAttr "networks" h.nets.nwvpn.wireguard then h.nets.nwvpn.wireguard.networks else []);
            };
          }
        ) (builtins.attrValues (vpnClients netname))
      )
      else
        [
          {
            wireguardPeerConfig = {
              PublicKey = netcfg.publicKey;
              AllowedIPs = netcfg.allowedIPs;
              Endpoint = netcfg.endpoint;
              PersistentKeepalive = netcfg.persistentKeepalive;
            };
          }
        ];
  };

  generateNetwork = _: netcfg: nameValuePair
    "20-${netcfg.ifname}" {
    matchConfig = {
      Name = "${netcfg.ifname}";
    };
    address = [
      "${netcfg.ip}/${toString netcfg.subnetMask}"
    ];
  } // optionalAttrs netcfg.server.enable {
    networkConfig = {
      IPForward = "ipv4";
      IPMasquerade = "yes";
    };
  };

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
in
{
  options = {
    ptsd.wireguard = {
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
                allowedIPs = mkOption {
                  type = with types; listOf str;
                };
                endpoint = mkOption {
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
                server = mkOption {
                  type = types.submodule {
                    options = {
                      enable = mkEnableOption "${config.ifname}-server";
                      listenPort = mkOption {
                        type = types.int;
                      };
                    };
                  };
                  default = {};
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
              };
            }
          )
        );
        default = {};
      };
    };
  };

  config = mkIf (enabledNetworks != {}) {
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
    } // optionalAttrs (natForwardNetworks != {}) {
      extraCommands = concatStringsSep "\n" (mapAttrsToList (_: netcfg: (genNatForwardUp netcfg.ifname netcfg.natForwardIf)) natForwardNetworks);
      extraStopCommands = concatStringsSep "\n" (mapAttrsToList (_: netcfg: (genNatForwardDown netcfg.ifname netcfg.natForwardIf)) natForwardNetworks);
    };

    boot.kernel.sysctl = optionalAttrs (natForwardNetworks != {}) {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv4.conf.default.forwarding" = true;
    };

    # will query all wireguard interfaces by default
    ptsd.nwtelegraf.inputs.wireguard = [ {} ];
  };
}
