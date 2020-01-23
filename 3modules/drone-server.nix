{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.drone-server;
in
{
  options = {
    ptsd.drone-server = {
      enable = mkEnableOption "drone-server";
      envConfig = mkOption { type = types.attrs; };
      envFile = mkOption {
        type = types.path;
        description = "env-file used for passing secret env-vars to the service";
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/drone-server";
      };
      port = mkOption {
        type = types.int;
        description = "port to listen on localhost for http traffic";
      };
    };
  };

  config = mkIf cfg.enable {

    users.groups.drone-server = {};
    users.users.drone-server = {
      group = "drone-server";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
    };

    systemd.services.drone-server = {
      description = "Drone CI Server";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.drone}/bin/drone-server";
        User = "drone-server";
        Restart = "on-failure";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        ReadWriteDirectories = cfg.dataDir;
        #AmbientCapabilities = "cap_net_bind_service";  # only needed for ports < 1024
        #CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = cfg.envFile;
      };
      environment = {
        DRONE_DATABASE_DRIVER = "sqlite3";
        DRONE_DATABASE_DATASOURCE = "${cfg.dataDir}/drone.sqlite";
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
