{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwvpn;
  universe = import <ptsd/2configs/universe.nix>;
in
{
  options = {
    ptsd.nwvpn = {
      enable = mkEnableOption "nwvpn";
      ip = mkOption {
        type = types.str;
        default = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
        example = "191.18.19.123";
      };
      publicKey = mkOption {
        type = types.str;
        default = "UeAoj/VLCmoWLGjAkFRXYLYeac/tLM2itmkq4GKz0zg=";
      };
      allowedIPs = mkOption {
        type = with types; listOf str;
        default = [ "191.18.19.0/24" ];
      };
      endpoint = mkOption {
        type = types.str;
        default = "159.69.186.234:55555";
      };
      ifname = mkOption {
        type = types.str;
        default = "nwvpn";
      };
      persistentKeepalive = mkOption {
        type = types.int;
        default = 21;
      };
      keyname = mkOption {
        type = types.str;
        default = "nwvpn.key";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions =
      [
        {
          assertion = config.networking.useNetworkd;
          message = "nwvpn only supports systemd-networkd.";
        }
      ];

    environment.systemPackages = [ pkgs.wireguard ];
    boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

    ptsd.secrets.files."${cfg.keyname}" = {
      owner = "systemd-network";
      group-name = "systemd-network";
      mode = "0440";
    };

    systemd.network = {

      netdevs."10-${cfg.ifname}" = {
        netdevConfig = {
          Name = "${cfg.ifname}";
          Kind = "wireguard";
          MTUBytes = "1300";
        };

        wireguardConfig = {
          PrivateKeyFile = config.ptsd.secrets.files."${cfg.keyname}".path;
        };

        wireguardPeers = [
          {
            wireguardPeerConfig = {
              PublicKey = cfg.publicKey;
              AllowedIPs = cfg.allowedIPs;
              Endpoint = cfg.endpoint;
              PersistentKeepalive = cfg.persistentKeepalive;
            };
          }
        ];
      };

      networks."20-${cfg.ifname}" = {
        matchConfig = {
          Name = "${cfg.ifname}";
        };
        address = [
          "${cfg.ip}/24"
        ];
      };

    };
  };
}
