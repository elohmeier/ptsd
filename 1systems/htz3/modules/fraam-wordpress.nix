{ config, lib, pkgs, ... }:
let
  user = config.services.nginx.user;
  group = config.services.nginx.group;

  poolConfig = {
    "pm" = "dynamic";
    "pm.max_children" = 40;
    "pm.start_servers" = 15;
    "pm.min_spare_servers" = 15;
    "pm.max_spare_servers" = 25;
    "pm.max_requests" = 500;
  };

  phpPackage = pkgs.php;
  phpEnv = { };
in
{

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    # package = pkgs.mysql-old; # uncomment to downgrade version
    bind = "127.0.0.1";

    ensureDatabases = [ "wordpress" ];
    ensureUsers = [
      {
        name = "nginx"; # authenticated via Unix socket authentication
        ensurePermissions = {
          "wordpress.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.phpfpm.pools.wordpress = {
    inherit user;
    inherit group;

    phpPackage = phpPackage;
    phpOptions = ''
      memory_limit = 512M
    '';
    phpEnv = phpEnv;

    settings = {
      "listen.mode" = "0660";
      "listen.owner" = user;
      "listen.group" = group;
    } // poolConfig;
  };

  # TODO: add https://github.com/yaoweibin/ngx_http_substitutions_filter_module
  services.nginx = {
    enable = true;
    serverNamesHashBucketSize = 128;

    # logError = "stderr debug";

    commonHttpConfig = ''
      charset UTF-8;
      port_in_redirect off;
    '';

    # nginx config from https://www.nginx.com/resources/wiki/start/topics/recipes/wordpress/
    virtualHosts = {
      "fraam.de www.fraam.de" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = config.ptsd.nwtraefik.ports.fraam-wwwstatic;
          }
        ];

        root = "/var/www/static";

        locations."~* \.(js|css|png|jpg|jpeg|gif|ico)$" = {
          extraConfig = ''
            expires max;
            log_not_found off;
          '';
        };
      };

      "dev.fraam.de" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = config.ptsd.nwtraefik.ports.fraam-wordpress;
          }
        ];

        root = "/var/www/wp";

        extraConfig = ''
          index index.php;
        '';

        locations."/favicon.ico" = {
          extraConfig = ''
            log_not_found off;
            access_log off;
          '';
        };

        locations."/robots.txt" = {
          extraConfig = ''
            allow all;
            log_not_found off;
            access_log off;
          '';
        };

        locations."/" = {
          extraConfig = "try_files $uri $uri/ /index.php?$args;";
        };

        locations."~ \.php$" = {
          extraConfig = ''
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_intercept_errors on;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_pass unix:${config.services.phpfpm.pools.wordpress.socket};
            fastcgi_param HTTPS on;
          '';
        };

        locations."~* \.(js|css|png|jpg|jpeg|gif|ico)$" = {
          extraConfig = ''
            expires max;
            log_not_found off;
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.ptsd.nwtraefik.ports.fraam-wordpress config.ptsd.nwtraefik.ports.fraam-wwwstatic ];
}
