{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwvpn;
  universe = import ../2configs/universe.nix;
in
{
  options = {
    ptsd.nwvpn = {
      enable = mkEnableOption "nwvpn";
      ip = mkOption {
        type = types.str;
        default = universe.nwvpn."${config.networking.hostName}".ip;
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
        default = "wg1"; # this shall be switched to "nwvpn" someday
      };
      persistentKeepalive = mkOption {
        type = types.int;
        default = 21;
      };
      #privateKeyFile = mkOption {
      #  default = (toString <secrets>) + "/nwvpn.key";
      #  type = types.str;
      #};
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      {
        environment.systemPackages = [ pkgs.wireguard ];
        boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

        ptsd.secrets.files."nwvpn.key" = {};
      }
      (
        mkIf (!config.networking.useNetworkd) {

          networking.wireguard.interfaces."${cfg.ifname}" = {
            ips = [ cfg.ip ];
            privateKeyFile = config.ptsd.secrets.files."nwvpn.key".path;
            peers = [
              {
                publicKey = cfg.publicKey;
                allowedIPs = cfg.allowedIPs;
                endpoint = cfg.endpoint;
                persistentKeepalive = cfg.persistentKeepalive;
              }
            ];
          };

          ptsd.nwmonit.extraConfig = [
            ''
              check process wireguard-${cfg.ifname} matching ^wg-crypt-${cfg.ifname}$
                start program = "${pkgs.systemd}/bin/systemctl start wireguard-${cfg.ifname}"
                stop program = "${pkgs.systemd}/bin/systemctl stop wireguard-${cfg.ifname}"
            ''
          ];
        }
      )
      (
        mkIf (config.networking.useNetworkd) {
          ptsd.secrets.files."nwvpn.key" = {
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
                PrivateKeyFile = config.ptsd.secrets.files."nwvpn.key".path;
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
        }
      )
    ]
  );
}
