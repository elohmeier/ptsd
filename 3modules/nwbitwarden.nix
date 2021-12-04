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
      extraConfig = mkOption {
        type = types.attrs;
      };
    };
  };

  config = mkIf cfg.enable {

    ptsd.secrets.files."bitwarden.env" = { dependants = [ "vaultwarden.service" ]; };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        domain = "https://${cfg.domain}";
        signupsAllowed = true;
        rocketAddress = "127.0.0.1"; # listen address
        rocketPort = toString config.ptsd.nwtraefik.ports.bitwarden; # listen port
        rocketLog = "critical";
        databaseUrl = "postgresql:///bitwarden";
      } // cfg.extraConfig;
      environmentFile = config.ptsd.secrets.files."bitwarden.env".path;
    };

    systemd.services.vaultwarden = {
      # ensure that postgres is running *before* running vaultwarden
      wants = [ "postgresql.service" ];
      after = [ "postgresql.service" ];

      # additional hardening
      serviceConfig = {
        CapabilityBoundingSet = "cap_net_bind_service";
        # TODO: evaluate socket with PrivateNetwork like in https://www.freedesktop.org/software/systemd/man/systemd-socket-proxyd.html
        #PrivateNetwork = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET"; # AF_UNIX needed for postgresql connection
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        RestrictSUIDSGID = true;
        NoNewPrivileges = true;
        IPAddressAllow = "localhost";
      };
    };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_12;
      ensureDatabases = [ "bitwarden" ];
      ensureUsers = [
        {
          name = "vaultwarden"; # authenticated via Unix socket authentication
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

    # TODO: configure as in
    # https://github.com/dani-garcia/bitwarden_rs/wiki/Fail2Ban-Setup
    # services.fail2ban.jails = {
    #   vaultwarden = { 

    #   };
    # };
  };
}
