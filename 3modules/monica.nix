{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.monica;

  poolConfig = {
    "pm" = "dynamic";
    "pm.max_children" = 32;
    "pm.start_servers" = 2;
    "pm.min_spare_servers" = 2;
    "pm.max_spare_servers" = 4;
    "pm.max_requests" = 500;
  };
  package = pkgs.monica.override { storagePath = "${cfg.dataDir}/storage"; };

  user = config.services.nginx.user;
  group = config.services.nginx.group;

  # see https://github.com/monicahq/monica/blob/master/docs/installation/providers/generic.md#prerequisites
  phpPackage = pkgs.php.withExtensions ({ all, ... }: with all;[
    bcmath
    curl
    fileinfo
    filter
    gd
    gmp
    iconv
    imagick
    intl
    json
    mbstring
    mysqli
    opcache
    openssl
    pdo
    pdo_mysql
    redis
    session
    sodium
    tokenizer
    xml
    zip
  ]);

  phpEnv = {
    APP_ENV = "production";
    APP_DEBUG = "\"false\"";
    APP_KEY = "${cfg.appKey}";
    APP_STORAGE_PATH = "${cfg.dataDir}/storage";
    APP_SERVICES_CACHE = "${cfg.dataDir}/cache/services.php";
    APP_PACKAGES_CACHE = "${cfg.dataDir}/cache/packages.php";
    APP_CONFIG_CACHE = "${cfg.dataDir}/cache/config.php";
    APP_ROUTES_CACHE = "${cfg.dataDir}/cache/routes-v7.php";
    APP_EVENTS_CACHE = "${cfg.dataDir}/cache/events.php";
    HASH_SALT = "${cfg.hashSalt}";
    HASH_LENGTH = "18";
    APP_URL = "https://${cfg.domain}/";
    DB_CONNECTION = "mysql";
    DB_UNIX_SOCKET = "/var/run/mysqld/mysqld.sock";
    DB_DATABASE = "monica";
    DB_USERNAME = user;
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
    APP_SIGNUP_DOUBLE_OPTIN = "\"false\"";
    APP_TRUSTED_PROXIES = "*";
    APP_TRUSTED_CLOUDFLARE = "\"false\"";
    LOG_CHANNEL = "daily";
    SENTRY_SUPPORT = "\"false\"";
    CHECK_VERSION = "\"false\"";
    CACHE_DRIVER = "database";
    SESSION_DRIVER = "file";
    SESSION_LIFETIME = "120";
    QUEUE_DRIVER = "sync";
    DEFAULT_MAX_UPLOAD_SIZE = "512000";
    DEFAULT_FILESYSTEM = "public";
    MFA_ENABLED = "\"false\"";
    ALLOW_STATISTICS_THROUGH_PUBLIC_API_ACCESS = "\"false\"";
    POLICY_COMPLIANT = "\"false\"";
  };
in
{
  options = {
    ptsd.monica = {
      enable = mkEnableOption "monica";
      appKey = mkOption {
        type = types.str;
      };
      hashSalt = mkOption {
        type = types.str;
      };
      mailPassword = mkOption {
        type = types.str;
      };
      domain = mkOption {
        type = types.str;
      };
      entryPoints = mkOption {
        type = with types; listOf str;
        default = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
      };
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/monica";
      };
    };
  };

  config = mkIf cfg.enable {

    services.phpfpm.pools.monica = {
      inherit user;
      inherit group;

      phpOptions = ''
        date.timezone = "Europe/Berlin"
      '';

      phpPackage = phpPackage;
      phpEnv = phpEnv;

      settings = {
        "listen.mode" = "0660";
        "listen.owner" = user;
        "listen.group" = group;
      } // poolConfig;
    };

    # Uncomment for debugging purposes.
    # environment = {
    #   systemPackages = [ phpPackage ];
    #   sessionVariables = phpEnv;
    # };
    # Use `su nginx -s /run/current-system/sw/bin/bash` to switch to the nginx user.

    systemd.services."monica-init" = {
      enable = true;
      description = "Initialize Monica database and directory structure";
      requires = [ "mysql.service" ];
      after = [ "mysql.service" ];
      wantedBy = [ "phpfpm-monica.service" ];
      path = [ phpPackage ];
      environment = phpEnv;

      script = ''
        cd "${package}/share/monica/"

        for i in *; do
          if [ "$i" == "storage" ]; then
            continue;
          fi

          rm -f "$STATE_DIRECTORY/$i"
          ln -s "${package}/share/monica/$i" "$STATE_DIRECTORY/$i"
        done

        cd "$STATE_DIRECTORY"

        mkdir -p cache
        mkdir -p storage/framework/cache
        mkdir -p storage/framework/sessions
        mkdir -p storage/framework/views

        php artisan monica:update --force -vv
      '';

      serviceConfig = {
        User = user;
        Group = group;
        ProtectHome = true;
        ProtectSystem = "full";
        Type = "oneshot";
        Restart = "no";
        StateDirectory = "monica";
      };
    };

    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      bind = "127.0.0.1";

      ensureDatabases = [ "monica" ];
      ensureUsers = [
        {
          name = "nginx"; # authenticated via Unix socket authentication
          ensurePermissions = {
            "monica.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    systemd.services.mysql-backup-monica = {
      description = "Backup Monica MySQL database";
      wantedBy = [ "multi-user.target" ];
      requires = [ "mysql.service" ];
      after = [ "mysql.service" ];
      script = ''
        mkdir -p /var/lib/mysql-backup
        ${pkgs.mariadb}/bin/mysqldump monica > /var/lib/mysql-backup/monica.sql
        chmod 600 /var/lib/mysql-backup/monica.sql
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
      };
      startAt = "*-*-* 05:00:00";
    };

    services.nginx = {
      enable = true;

      virtualHosts = {
        "${cfg.domain}" = {
          listen = [
            {
              addr = "127.0.0.1";
              port = config.ptsd.nwtraefik.ports.nginx-monica;
            }
          ];

          root = "${cfg.dataDir}/public";

          locations."/" = {
            priority = 1;
            index = "index.php";
            extraConfig = ''try_files $uri $uri/ /index.php;'';
          };

          locations."~ \.php$" = {
            extraConfig = ''
              try_files $uri $uri/ /index.php;
              include ${pkgs.nginx}/conf/fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param REDIRECT_STATUS 200;
              fastcgi_pass unix:${config.services.phpfpm.pools.monica.socket};
              fastcgi_param HTTPS on;
            '';
          };
        };
      };
    };

    ptsd.nwtraefik.services = [
      {
        name = "nginx-monica";
        rule = "Host(`${cfg.domain}`)";
        entryPoints = cfg.entryPoints;
      }
    ];
  };

}
