{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwvpn-server;
  universe = import <ptsd/2configs/universe.nix>;
  vpnClients = filterAttrs (hostname: hostcfg: hostname != config.networking.hostName && hasAttrByPath [ "nets" "nwvpn" ] hostcfg) universe.hosts;
in
{
  options = {
    ptsd.nwvpn-server = {
      enable = mkEnableOption "nwvpn-server";
      ip = mkOption {
        type = types.str;
        default = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
        example = "191.18.19.123";
      };
      ifname = mkOption {
        type = types.str;
        default = "nwvpn";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [
        {
          assertion = config.networking.useNetworkd;
          message = "nwvpn-server only supports systemd-networkd.";
        }
      ];

    ptsd.nwvpn.enable = lib.mkForce false; # disable vpn client

    boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
    environment.systemPackages = [ pkgs.wireguard ];

    networking.firewall.allowedUDPPorts = [ 55555 ];

    ptsd.secrets.files."nwvpn.key" = {
      owner = "systemd-network";
      mode = "0440";
    };

    users.groups.keys.members = [ "systemd-network" ];

    systemd.network = {
      netdevs."10-${cfg.ifname}" = {
        netdevConfig = {
          Name = cfg.ifname;
          Kind = "wireguard";
          MTUBytes = "1300";
        };

        wireguardConfig = {
          ListenPort = 55555;
          PrivateKeyFile = config.ptsd.secrets.files."nwvpn.key".path;
        };

        wireguardPeers = map (
          h: {
            wireguardPeerConfig = {
              PublicKey = h.nets.nwvpn.wireguard.pubkey;
              AllowedIPs = [ "${h.nets.nwvpn.ip4.addr}/32" ] ++ (if builtins.hasAttr "networks" h.nets.nwvpn.wireguard then h.nets.nwvpn.wireguard.networks else []);
            };
          }
        ) (builtins.attrValues vpnClients);
      };

      networks = {
        "20-${cfg.ifname}" = {
          matchConfig = {
            Name = cfg.ifname;
          };
          address = [
            "${cfg.ip}/24"
          ];
          networkConfig = {
            IPForward = "ipv4";
            IPMasquerade = "yes";
          };
        };
      };
    };
  };


}
