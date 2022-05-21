{ config, lib, pkgs, ... }:

let
  domain = "pm.fraam.de";
  pkg = pkgs.kanboard.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "kanboard";
      repo = "kanboard";
      rev = "v1.2.22";
      sha256 = "sha256-WG2lTPpRG9KQpRdb+cS7CqF4ZDV7JZ8XtNqAI6eVzm0=";
    };
    patches = [
      ./0001-change-logo-to-fraam-steuerrad.patch
    ];
  });
in
{
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

    virtualHosts.${domain} = {
      listen = [
        {
          addr = "127.0.0.1";
          port = config.ptsd.ports.nginx-kanboard;
        }
      ];
      root =
        let
          plugins = pkgs.symlinkJoin {
            name = "kanboard-plugins";
            paths = [
              pkgs.kanboard-plugin-google-auth
            ];
          };
          kb-config = pkgs.writeText "kanboard-config.php" ''
            <?php
            define("DATA_DIR", "/var/lib/kanboard/");
            define("CACHE_DRIVER", "file");
            define("CACHE_DIR", "/var/cache/kanboard");
            define("FILES_DIR", DATA_DIR.DIRECTORY_SEPARATOR."files");
            define("MAIL_CONFIGURATION", true);
            define("MAIL_FROM", "kanboard@fraam.de");
            define("MAIL_TRANSPORT", "smtp");
            define("MAIL_SMTP_HOSTNAME", "smtp-relay.gmail.com");
            define("MAIL_SMTP_PORT", 587);
            define("MAIL_SMTP_USERNAME", "");
            define("MAIL_SMTP_PASSWORD", "");
            define("MAIL_SMTP_HELO_NAME", null);
            define("MAIL_SMTP_ENCRYPTION", "tls");
            define("DB_RUN_MIGRATIONS", true);
            define("DB_DRIVER", "postgres");
            define("DB_USERNAME", "");
            define("DB_HOSTNAME", "/run/postgresql");
            define("DB_NAME", "kanboard");
            define("REVERSE_PROXY_AUTH", false);
            define("ENABLE_URL_REWRITE", true);
            define("HIDE_LOGIN_FORM", true);
            define("DISABLE_LOGOUT", false);
            // Comma separated list of fields to not synchronize when using external authentication providers
            define("EXTERNAL_AUTH_EXCLUDE_FIELDS", "username");

            // Enable or disable displaying group-memberships in userlist (true by default)
            define("SHOW_GROUP_MEMBERSHIPS_IN_USERLIST", true);

            // Limit number of groups to display in userlist (The full list of group-memberships is always shown, ...
            // ... when hovering the mouse over the group-icon of a given user!)
            // If set to 0 ALL group-memberships will be listed (7 by default)
            define("SHOW_GROUP_MEMBERSHIPS_IN_USERLIST_WITH_LIMIT", 7);
            define("PLUGINS_DIR", "${plugins}/plugins");
            //define("PLUGIN_INSTALLER", true);
          '';
        in
        pkgs.buildEnv {
          name = "kanboard-configured";
          paths = [
            (pkgs.runCommand "kanboard-over" { meta.priority = 0; } ''
              mkdir -p $out
              for f in index.php jsonrpc.php ; do
                echo "<?php require('$out/config.php');" > $out/$f
                tail -n+2 ${pkg}/share/kanboard/$f \
                  | sed 's^__DIR__^"${pkg}/share/kanboard"^' >> $out/$f
              done
              ln -s /var/lib/kanboard $out/data
              ln -s ${kb-config} $out/config.php
            '')
            { outPath = "${pkg}/share/kanboard"; meta.priority = 10; }
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

  ptsd.nwtraefik.services = [
    {
      name = "nginx-kanboard";
      rule = "Host(`${domain}`)";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
    }
  ];
}
