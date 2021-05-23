{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.navidrome;
in
{
  options = {
    ptsd.navidrome = {
      enable = mkEnableOption "navidrome";

      # TODO: add config
    };
  };

  config = mkIf cfg.enable {

    systemd.services.navidrome =
      {
        description = "Navidrome Music Server";
        after = [ "remote-fs.target" "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.navidrome}/bin/navidrome";
          TimeoutStopSec = 20;
          KillMode = "process";
          DynamicUser = true;
          Restart = "on-failure";
          AmbientCapabilities = "cap_net_bind_service";
          CapabilityBoundingSet = "cap_net_bind_service";
          NoNewPrivileges = true;
          LimitNPROC = 64;
          LimitNOFILE = 64;
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          StateDirectory = "navidrome";
          WorkingDirectory = "/var/lib/navidrome";
          ProtectControlGroups = true;
          ProtectClock = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          RestrictNamespaces = true;
          DevicePolicy = "closed";
          RestrictRealtime = true;
          SystemCallFilter = "@system-service";
          SystemCallErrorNumber = "EPERM";
          SystemCallArchitectures = "native";
        };
      };
  };
}
