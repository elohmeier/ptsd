{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.kanboard;
in
{
  options.ptsd.kanboard = {
    enable = mkEnableOption "kanboard";
    domain = mkOption {
      type = types.str;
      default = "localhost";
    };
    entryPoints = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    package = mkOption {
      type = types.package;
      default = pkgs.kanboard;
    };
  };

  config = mkIf cfg.enable {

    services.phpfpm.pools.kanboard = {
      user = "kanboard";
      group = "kanboard";
      settings = {
        "listen.group" = "nginx";
        "pm" = "dynamic";
        "pm.max_children" = 32;
        "pm.start_servers" = 2;
        "pm.min_spare_servers" = 2;
        "pm.max_spare_servers" = 4;
        "pm.max_requests" = 500;
      };
    };
    users.users.kanboard = {
      isSystemUser = true;
      group = "kanboard";
    };
    users.groups.kanboard = { };

    services.nginx = {
      enable = true;

      virtualHosts.${cfg.domain} = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.ports.nginx-kanboard;
          }
        ];
        root =
          let
            kb-config = pkgs.writeText "kanboard-config.php" ''
              <?php
              define("DATA_DIR", "/var/lib/kanboard/");
              define("CACHE_DRIVER", "file");
              define("CACHE_DIR", "/var/cache/kanboard");
              define("FILES_DIR", DATA_DIR.DIRECTORY_SEPARATOR."files");
              define("MAIL_CONFIGURATION", true);
              define("MAIL_FROM", "replace-me@kanboard.local");
              define("MAIL_TRANSPORT", "smtp");
              define("MAIL_SMTP_HOSTNAME", "");
              define("MAIL_SMTP_PORT", 25);
              define("MAIL_SMTP_USERNAME", "");
              define("MAIL_SMTP_PASSWORD", "");
              define("MAIL_SMTP_HELO_NAME", null); // valid: null (default), or FQDN
              define("MAIL_SMTP_ENCRYPTION", null); // Valid values are null (not a string "null"), "ssl" or "tls"
              define("DB_RUN_MIGRATIONS", true);
              define("DB_DRIVER", "postgres");
              define("DB_USERNAME", ""); // needed, default is root
              define("DB_HOSTNAME", "/run/postgresql");
              define("DB_NAME", "kanboard");
              define("REVERSE_PROXY_AUTH", false);
              // Header name to use for the username
              define("REVERSE_PROXY_USER_HEADER", "REMOTE_USER");
              // Username of the admin, by default blank
              define("REVERSE_PROXY_DEFAULT_ADMIN", "");
              // Header name to use for the username
              define("REVERSE_PROXY_EMAIL_HEADER", "REMOTE_EMAIL");
              // Default domain to use for setting the email address
              define("REVERSE_PROXY_DEFAULT_DOMAIN", "");
              define("ENABLE_URL_REWRITE", true);
              define("HIDE_LOGIN_FORM", false);
              define("DISABLE_LOGOUT", false);
              // Comma separated list of fields to not synchronize when using external authentication providers
              define("EXTERNAL_AUTH_EXCLUDE_FIELDS", "username");

              // Enable or disable displaying group-memberships in userlist (true by default)
              define("SHOW_GROUP_MEMBERSHIPS_IN_USERLIST", true);

              // Limit number of groups to display in userlist (The full list of group-memberships is always shown, ...
              // ... when hovering the mouse over the group-icon of a given user!)
              // If set to 0 ALL group-memberships will be listed (7 by default)
              define("SHOW_GROUP_MEMBERSHIPS_IN_USERLIST_WITH_LIMIT", 7);
            '';
          in
          pkgs.buildEnv {
            name = "kanboard-configured";
            paths = [
              (pkgs.runCommand "kanboard-over" { meta.priority = 0; } ''
                mkdir -p $out
                for f in index.php jsonrpc.php ; do
                  echo "<?php require('$out/config.php');" > $out/$f
                  tail -n+2 ${cfg.package}/share/kanboard/$f \
                    | sed 's^__DIR__^"${cfg.package}/share/kanboard"^' >> $out/$f
                done
                ln -s /var/lib/kanboard $out/data
                ln -s ${kb-config} $out/config.php
              '')
              { outPath = "${cfg.package}/share/kanboard"; meta.priority = 10; }
            ];
          };

        locations = {
          "/" = {
            index = "index.php";
            tryFiles = "$uri $uri/ /index.php$is_args$args";
          };
          "~ \\.php$" = {
            tryFiles = "$uri =404";
            extraConfig = ''
              fastcgi_split_path_info ^(.+\.php)(/.+)$;
              fastcgi_pass unix:${config.services.phpfpm.pools.kanboard.socket};
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_index index.php;
              include ${pkgs.nginx}/conf/fastcgi_params;
            '';
          };
        };
      };
    };

    systemd.tmpfiles.rules = [
      "d '/var/cache/kanboard' - kanboard kanboard - -"
      "d '/var/lib/kanboard' - kanboard kanboard - -"
    ];

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "kanboard" ];
      ensureUsers = [
        {
          name = "kanboard";
          ensurePermissions."DATABASE kanboard" = "ALL PRIVILEGES";
        }
      ];
    };

    # ptsd.nwtraefik.services = [
    #   {
    #     name = "nginx-kanboard";
    #     rule = "Host(`${cfg.domain}`)";
    #     entryPoints = cfg.entryPoints;
    #   }
    # ];


  };











}
