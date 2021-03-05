{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.traggo;
in
{
  options = {
    ptsd.traggo = {
      enable = mkEnableOption "traggo time-tracking";
      package = mkOption {
        default = pkgs.traggo;
        type = types.package;
      };
      port = mkOption {
        default = 3030;
        type = types.int;
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.traggo = {
      description = "traggo time-tracking";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # see https://traggo.net/config/#properties
      environment = {
        TRAGGO_PORT = toString cfg.port;
        TRAGGO_LOG_LEVEL = "info";
        TRAGGO_DATABASE_DIALECT = "sqlite3";
        TRAGGO_DATABASE_CONNECTION = "/var/lib/traggo/traggo.db";
      };

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/traggo";
        DynamicUser = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        LockPersonality = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        Restart = "on-failure";
        PrivateTmp = "true";
        ProtectSystem = "full";
        ProtectHome = "true";
        NoNewPrivileges = "true";
        StateDirectory = "traggo";
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        RestrictSUIDSGID = true;
        IPAddressAllow = "localhost";
        MemoryDenyWriteExecute = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        PrivateDevices = true;
        PrivateUsers = true;
      };
    };
  };
}
