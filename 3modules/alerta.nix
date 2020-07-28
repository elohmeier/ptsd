{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.alerta;

  alertaConf = pkgs.writeTextFile {
    name = "alertad.conf";
    text = ''
      DATABASE_URL = '${cfg.databaseUrl}'
      DATABASE_NAME = '${cfg.databaseName}'
      LOG_FILE = '/var/log/alerta/alertad.log'
      LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
      CORS_ORIGINS = [ ${concatMapStringsSep ", " (s: "\"" + s + "\"") cfg.corsOrigins} ];
      AUTH_REQUIRED = ${if cfg.authenticationRequired then "True" else "False"}
      SIGNUP_ENABLED = ${if cfg.signupEnabled then "True" else "False"}
      ${cfg.extraConfig}
    '';
  };
in
{
  options.ptsd.alerta = {
    enable = mkEnableOption "alerta";

    port = mkOption {
      type = types.int;
      default = 5000;
      description = "Port of Alerta";
    };

    bind = mkOption {
      type = types.str;
      default = "0.0.0.0";
      example = literalExample "0.0.0.0";
      description = "Address to bind to. The default is to bind to all addresses";
    };

    databaseUrl = mkOption {
      type = types.str;
      description = "URL of the MongoDB or PostgreSQL database to connect to";
      example = "mongodb://localhost";
    };

    databaseName = mkOption {
      type = types.str;
      description = "Name of the database instance to connect to";
      default = "monitoring";
      example = "monitoring";
    };

    corsOrigins = mkOption {
      type = types.listOf types.str;
      description = "List of URLs that can access the API for Cross-Origin Resource Sharing (CORS)";
      example = [ "http://localhost" "http://localhost:5000" ];
      default = [ "http://localhost" "http://localhost:5000" ];
    };

    authenticationRequired = mkOption {
      type = types.bool;
      description = "Whether users must authenticate when using the web UI or command-line tool";
      default = false;
    };

    signupEnabled = mkOption {
      type = types.bool;
      description = "Whether to prevent sign-up of new users via the web UI";
      default = true;
    };

    extraConfig = mkOption {
      description = "These lines go into alertad.conf verbatim.";
      default = "";
      type = types.lines;
    };

    serverPackage = mkOption {
      type = types.package;
      default = pkgs.python3Packages.alerta-server;
    };

    clientPackage = mkOption {
      type = types.package;
      default = pkgs.python3Packages.alerta;
    };
  };

  config = mkIf cfg.enable {

    systemd.services.alerta = {
      description = "Alerta Monitoring System";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" ];
      environment = {
        ALERTA_SVR_CONF_FILE = alertaConf;
      };
      serviceConfig = {
        ExecStart = "${cfg.serverPackage}/bin/alertad run --port ${toString cfg.port} --host ${cfg.bind}";
        DynamicUser = true;
        LogsDirectory = "alerta";
        Restart = "on-failure";
        PrivateTmp = "true";
        ProtectSystem = "full";
        ProtectHome = "true";
        NoNewPrivileges = "true";
      };
    };

    environment.systemPackages = [ cfg.clientPackage ];
  };
}
