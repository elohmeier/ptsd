{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nwmonica;
in
{
  options = {
    services.nwmonica = {
      enable = mkEnableOption "nwmonica";
      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/monica";
      };
      appKey = mkOption {
        type = types.str;
      };
      hashSalt = mkOption {
        type = types.str;
      };
      dbPassword = mkOption {
        type = types.str;
      };
      mailPassword = mkOption {
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    docker-containers = {
      monica-db = {
        image = "mariadb:10";
        volumes = [
          "${cfg.dataDir}/mysql:/var/lib/mysql"
        ];
        environment = {
          MYSQL_RANDOM_ROOT_PASSWORD = "yes";
          MYSQL_DATABASE = "monica";
          MYSQL_USER = "monica";
          MYSQL_PASSWORD = cfg.dbPassword;
        };
        extraDockerOptions = [
          "--network=docker-monica-net"
        ];
      };

      monica = {
        image = "monicahq/monicahq:v2.15.1-apache";
        volumes = [
          "${cfg.dataDir}/storage:/var/www/monica/storage"
        ];
        environment = {
          APP_ENV = "production";
          APP_DEBUG = "false";
          APP_KEY = "${cfg.appKey}";
          HASH_SALT = "${cfg.hashSalt}";
          HASH_LENGTH = "18";
          APP_URL = "https://monica.services.nerdworks.de";
          DB_CONNECTION = "mysql";
          DB_HOST = "docker-monica-db.service";
          DB_PORT = "3306";
          DB_DATABASE = "monica";
          DB_USERNAME = "monica";
          DB_PASSWORD = "${cfg.dbPassword}";
          DB_USE_UTF8MB4 = "true";
          MAIL_DRIVER = "smtp";
          MAIL_HOST = "smtp.dd24.net";
          MAIL_PORT = "25";
          MAIL_USERNAME = "info@nerdworks.de";
          MAIL_PASSWORD = "${cfg.mailPassword}";
          MAIL_ENCRYPTION = "TLS";
          MAIL_FROM_ADDRESS = "info@nerdworks.de";
          MAIL_FROM_NAME = "NerdCRM";
          APP_EMAIL_NEW_USERS_NOTIFICATION = "info@nerdworks.de";
          APP_DEFAULT_LOCALE = "de";
          APP_DISABLE_SIGNUP = "true";
          APP_SIGNUP_DOUBLE_OPTIN = "false";
          APP_TRUSTED_PROXIES = "*";
          APP_TRUSTED_CLOUDFLARE = "false";
          LOG_CHANNEL = "daily";
          SENTRY_SUPPORT = "false";
          CHECK_VERSION = "false";
          CACHE_DRIVER = "database";
          SESSION_DRIVER = "file";
          SESSION_LIFETIME = "120";
          QUEUE_DRIVER = "sync";
          DEFAULT_MAX_UPLOAD_SIZE = "512000";
          DEFAULT_FILESYSTEM = "public";
          MFA_ENABLED = "false";
          ALLOW_STATISTICS_THROUGH_PUBLIC_API_ACCESS = "false";
          POLICY_COMPLIANT = "false";
          REQUIRES_SUBSCRIPTION = "false";
        };
        extraDockerOptions = [
          "--network=docker-monica-net"
          "--label=traefik.enable=true"
          "--label=traefik.backend=monica"
          "--label=traefik.domain=services.nerdworks.de"
          "--label=traefik.frontend.rule=Host:monica.services.nerdworks.de"
          "--label=traefik.frontend.entryPoints=http,https"
        ];
      };
    };

    # systemd.services.docker-monica-net = {
    #   wantedBy = [ "multi-user.target" ];
    #   after = [ "docker.service" "docker.socket" ];
    #   requires = [ "docker.service" "docker.socket" ];
    #   before = [ "docker-monica.service" "docker-monica-db.service" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.docker}/bin/docker network create %n";
    #     ExecStartPre = "-${pkgs.docker}/bin/docker network rm %n";
    #     ExecStop = "${pkgs.docker}/bin/docker network rm %n";
    #     Type = "oneshot";
    #   };
    # };
  };
}
