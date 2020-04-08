{ config, lib, pkgs, ... }:

let
  user = config.services.nginx.user;
  group = config.services.nginx.group;

  poolConfig = {
    "pm" = "dynamic";
    "pm.max_children" = 32;
    "pm.start_servers" = 2;
    "pm.min_spare_servers" = 2;
    "pm.max_spare_servers" = 4;
    "pm.max_requests" = 500;
  };

  phpPackage = pkgs.php;
  phpEnv = {};
in
{
  containers.wpjail = {
    autoStart = true;
    hostBridge = "br0";
    privateNetwork = true;
    bindMounts = {
      "/var/lib/mysql" = {
        hostPath = "/home/enno/Downloads/wp_mysql";
        isReadOnly = false;
      };
      "/var/www" = {
        hostPath = "/home/enno/Downloads/CMS";
        isReadOnly = false;
      };
    };

    config =
      { config, pkgs, ... }:
        {
          imports = [
            <ptsd>
            <ptsd/2configs>
          ];

          boot.isContainer = true;

          networking = {
            useHostResolvConf = false;
            nameservers = [ "8.8.8.8" "8.8.4.4" ];
            useNetworkd = true;
            interfaces.eth0.useDHCP = true;
          };

          time.timeZone = "Europe/Berlin";

          i18n = {
            defaultLocale = "de_DE.UTF-8";
            supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
          };

          services.mysql = {
            enable = true;
            package = pkgs.mariadb;
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

            commonHttpConfig = ''
              charset UTF-8;
            '';

            # nginx config from https://www.nginx.com/resources/wiki/start/topics/recipes/wordpress/
            virtualHosts = {
              "192.168.0.2" = {
                listen = [
                  {
                    addr = "192.168.0.2";
                    port = 80;
                  }
                ];

                root = "/var/www";

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
                    fastcgi_param SERVER_NAME fraam.de;
                    fastcgi_param HTTP_HOST fraam.de;
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

          networking.firewall.allowedTCPPorts = [ 80 ];
        };
  };

  ptsd.nwtraefik.services = [
    {
      name = "fraam-www";
      rule = "Host:ws1.host.nerdworks.de";
      url = "http://192.168.0.2";
    }
  ];
}
