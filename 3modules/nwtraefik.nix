{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.nwtraefik;
in
{
  options = {
    ptsd.nwtraefik = {
      enable = mkEnableOption "nwtraefik";

      ports = mkOption {
        internal = true;
        description = "The HTTP ports used by Traefik backends.";
        type = types.attrsOf types.int;
      };

      httpPort = mkOption {
        type = types.int;
        default = 80;
      };

      httpsPort = mkOption {
        type = types.int;
        default = 443;
      };

      logLevel = mkOption {
        type = types.str;
        default = "ERROR";
      };

      services = mkOption {
        type = with types; listOf attrs;
        default = [];
        example = [
          {
            name = "nerdworkswww";
            rule = "Host:www.nerdworks.de";
          }
        ];
      };
    };
  };

  config = mkMerge [
    {
      ptsd.nwtraefik.ports = {
        droneci = 10050;
        ffoxsync = 10077;
        nerdworkswww = 1080;
        nwgit = 10055;
      };
    }
    (
      mkIf cfg.enable {
        assertions =
          [
            {
              assertion = config.ptsd.lego.enable;
              message = "nwtraefik requires lego to be enabled.";
            }
          ];

        services.traefik = {
          enable = true;
          configOptions = {
            logLevel = cfg.logLevel;
            accessLog = {
              filePath = "/var/lib/traefik/access.log";
              bufferingSize = 100;
            };
            defaultEntryPoints = [ "https" "http" ];
            entryPoints = {
              http = {
                address = ":${toString cfg.httpPort}";
                redirect.entryPoint = "https";
              };
              https = {
                address = ":${toString cfg.httpsPort}";
                tls = {
                  certificates = [
                    {
                      certFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
                      keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
                    }
                  ];
                };
              };
            };

            file = {};

            frontends = builtins.listToAttrs (
              map (
                svc: {
                  name = svc.name;
                  value = {
                    entryPoints = [ "https" "http" ];
                    backend = svc.name;
                    routes.r1.rule = svc.rule;
                    passHostHeader = true;
                  };
                }
              ) cfg.services
            );

            backends = builtins.listToAttrs (
              map (
                svc: {
                  name = svc.name;
                  value = {
                    servers.s1.url = "http://localhost:${toString cfg.ports."${svc.name}"}";
                  };
                }
              ) cfg.services
            );
          };
        };

        networking = {
          firewall = {
            allowedTCPPorts = [ cfg.httpPort cfg.httpsPort ];
          };
        };

        users.groups.lego = {
          members = [ "traefik" ];
        };

      }
    )
  ];
}
