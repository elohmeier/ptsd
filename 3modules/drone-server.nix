{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.drone-server;
in
{
  options = {
    ptsd.drone-server = {
      enable = mkEnableOption "drone-server";
      package = mkOption {
        type = types.package;
        default = pkgs.drone;
        defaultText = "pkgs.drone";
      };
      envConfig = mkOption { type = types.attrs; };
      envFile = mkOption {
        type = types.path;
        description = "env-file used for passing secret env-vars to the service";
      };
      port = mkOption {
        type = types.int;
        description = "port to listen on localhost for http traffic";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.drone-server = {
      description = "Drone CI Server";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" "network-online.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/drone-server";
        EnvironmentFile = cfg.envFile;
        StartLimitInterval = 86400;
        StartLimitBurst = 5;
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        DynamicUser = true;
        StateDirectory = "drone-server";
        Restart = "on-failure";
      };
      environment = {
        DRONE_DATABASE_DRIVER = "sqlite3";
        DRONE_DATABASE_DATASOURCE = "/var/lib/drone-server/drone.sqlite";
        DRONE_SERVER_PORT = "127.0.0.1:${toString cfg.port}";
        DRONE_SERVER_HOST = "localhost";
        DRONE_SERVER_PROTO = "http";
        DRONE_TLS_AUTOCERT = "false";
        DRONE_RUNNER_CAPACITY = "0";
      }
      // cfg.envConfig
      ;
    };
  };
}
