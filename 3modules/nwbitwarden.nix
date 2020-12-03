{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwbitwarden;
in
{

  options = {
    ptsd.nwbitwarden = {
      enable = mkEnableOption "nwbitwarden";
      domain = mkOption {
        type = types.str;
      };
      entryPoints = mkOption {
        type = with types; listOf str;
        default = [ "nwvpn-http" "nwvpn-https" ];
      };
    };
  };

  config = mkIf cfg.enable {

    services.bitwarden_rs = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        domain = "https://${cfg.domain}";
        signupsAllowed = true;
        rocketAddress = "127.0.0.1"; # listen address
        rocketPort = toString config.ptsd.nwtraefik.ports.bitwarden; # listen port
        rocketLog = "critical";
        databaseUrl = "postgresql:///bitwarden";
      };
    };

    # ensure that postgres is running *before* running bitwarden_rs
    systemd.services.bitwarden_rs = {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
    };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "bitwarden" ];
      ensureUsers = [
        {
          name = "bitwarden_rs"; # authenticated via Unix socket authentication
          ensurePermissions."DATABASE bitwarden" = "ALL PRIVILEGES";
        }
      ];
    };

    ptsd.nwtraefik = {
      services = [
        {
          name = "bitwarden";
          entryPoints = cfg.entryPoints;
          rule = "Host(`${cfg.domain}`)";
        }
      ];
    };
  };
}
