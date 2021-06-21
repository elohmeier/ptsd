{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.loki;

  prettyJSON = conf:
    pkgs.runCommand "loki-config.json" { } ''
      echo '${builtins.toJSON conf}' | ${pkgs.jq}/bin/jq 'del(._module)' > $out
    '';
in
{
  options.ptsd.loki = {
    enable = mkEnableOption "loki";
    config = mkOption {
      type = (pkgs.formats.json { }).type;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.grafana-loki;
      defaultText = "pkgs.grafana-loki";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.loki = {
      description = "Loki Log Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      serviceConfig = {
        # execution
        ExecStart = "${cfg.package}/bin/loki --config.file=${prettyJSON cfg.config}";
        Restart = "on-failure";

        # folders
        StateDirectory = "loki";

        # hardening
        DynamicUser = true;
        StartLimitBurst = 5;
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        UMask = "0066";
      };
    };

  };

}
