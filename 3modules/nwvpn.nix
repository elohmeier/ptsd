{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwvpn;
in
{
  options = {
    ptsd.nwvpn = {
      enable = mkEnableOption "nwvpn";
      ip = mkOption {
        type = types.str;
        example = "191.18.19.123";
      };
      privateKey = mkOption {
        type = types.str;
      };
      ifname = mkOption {
        type = types.str;
        default = "wg1"; # this shall be switched to "nwvpn" someday
      };
    };
  };

  config = mkIf cfg.enable {
    networking.wireguard.interfaces."${cfg.ifname}" = {
      ips = [ cfg.ip ];
      privateKey = cfg.privateKey;
      peers = [
        {
          publicKey = "UeAoj/VLCmoWLGjAkFRXYLYeac/tLM2itmkq4GKz0zg=";
          allowedIPs = [ "191.18.19.0/24" ];
          endpoint = "159.69.186.234:55555";
          persistentKeepalive = 21;
        }
      ];
    };
  };
}
