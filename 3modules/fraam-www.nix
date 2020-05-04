{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraam-www;
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
  phpEnv = {};
in
{
  options = {
    ptsd.fraam-www = {
      enable = mkEnableOption "fraam-www";
      containerAddress = mkOption {
        type = types.str;
        default = "192.168.100.15";
        description = "IP address of the container in the private host/container-network";
      };
      hostAddress = mkOption {
        type = types.str;
        default = "192.168.100.10";
        description = "IP address of the host in the private host/container-network";
      };
      mysqlPath = mkOption {
        default = "/var/lib/fraam-www/mysql";
      };
      wwwPath = mkOption {
        default = "/var/lib/fraam-www/www";
      };
      traefikFrontendRule = mkOption {
        default = "Host:www.fraam.de,fraam.de";
      };
    };
  };

  config = mkIf cfg.enable {

    containers.wpjail = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = {
        "/var/lib/mysql" = {
          #hostPath = "/home/enno/Downloads/wp_mysql";
          hostPath = "${cfg.mysqlPath}";
          isReadOnly = false;
        };
        "/var/www" = {
          #hostPath = "/home/enno/Downloads/CMS";
          hostPath = "${cfg.wwwPath}";
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
                "${cfg.containerAddress}" = {
                  listen = [
                    {
                      addr = "${cfg.containerAddress}";
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
        rule = cfg.traefikFrontendRule;
        url = "http://${cfg.containerAddress}:80";
        auth.forward = {
          address = "http://localhost:4181";
          authResponseHeaders = [ "X-Forwarded-User" ];
        };
      }
    ];

    ptsd.traefik-forward-auth = {
      enable = true;
      envFile = toString <secrets/traefik-forward-auth.env>;
    };

    system.activationScripts.initialize-fraam-www = stringAfter [ "users" "groups" ] ''
      mkdir -p ${cfg.mysqlPath}
      mkdir -p ${cfg.wwwPath}
    '';
  };
}
