{ config, lib, pkgs, ... }:

# listens on port 4181, cannot be changed as of
# https://github.com/thomseddon/traefik-forward-auth/blob/eec62eb03a9c1538df07ff0f2a2a5fc6e757ac71/cmd/main.go

with lib;
let
  cfg = config.ptsd.traefik-forward-auth;
in
{
  options = {
    ptsd.traefik-forward-auth = {
      enable = mkEnableOption "traefik-forward-auth";

      package = mkOption {
        type = types.package;
        default = pkgs.traefik-forward-auth;
        defaultText = "pkgs.traefik-forward-auth";
      };

      envFile = mkOption {
        type = types.path;
      };

      env = mkOption {
        type = types.attrs;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.traefik-forward-auth = {
      description = "Traefik forward authentication service";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/cmd";
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        PrivateDevices = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        AmbientCapabilities = "cap_net_bind_service";
        NoNewPrivileges = true;
        DynamicUser = true;
        Restart = "on-failure";
        EnvironmentFile = cfg.envFile;
        ReadOnlyPaths = cfg.envFile;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        RestrictSUIDSGID = true;
        IPAddressAllow = "localhost";
      };
      environment = {
        LOG_LEVEL = "warn";
      } // cfg.env;
    };

  };
}
