{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ptsd.navidrome;

  configOptions = {
    MusicFolder = cfg.musicFolder;
    DataFolder = "/var/lib/navidrome";
    ScanSchedule = "@every 1h";
    LogLevel = "info";
    Port = config.ptsd.ports.navidrome;
    Address = "127.0.0.1";
    BaseUrl = "/music"; # only the path (e.g. /music)
  };

  configFile =
    pkgs.runCommand "config.toml"
      {
        buildInputs = [ pkgs.remarshal ];
        preferLocalBuild = true;
      }
      ''
        remarshal -if json -of toml \
          < ${pkgs.writeText "config.json" (builtins.toJSON configOptions)} \
          > $out
      '';
in
{
  options = {
    ptsd.navidrome = {
      enable = mkEnableOption "navidrome";
      musicFolder = mkOption { type = types.path; };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.navidrome = {
      description = "Navidrome Music Server";
      after = [
        "remote-fs.target"
        "network.target"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.navidrome}/bin/navidrome --configfile ${configFile}";
        TimeoutStopSec = 20;
        KillMode = "process";
        DynamicUser = true;
        Restart = "on-failure";
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1024;
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
        UMask = "0066";
      };
    };

  };
}
