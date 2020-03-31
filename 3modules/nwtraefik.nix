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
        type = types.listOf (
          types.submodule {
            options = {
              name = mkOption { type = types.str; };
              rule = mkOption { type = types.str; };
              auth = mkOption { type = types.attrs; default = {}; };
            };
          }
        );
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
        acme-dns = 10049;
        droneci = 10050;
        ffoxsync = 10077;
        grafana = 10089;
        influxdb = 10078;
        kapacitor = 10079;
        nerdworkswww = 1080;
        nextcloud = 1082;
        nginx-monica = 10090;
        nginx-htz2 = 10091;
        nwgit = 10055;
        radicale = 5232;
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
                  minVersion = "VersionTLS12";
                  sniStrict = true;
                  cipherSuites = [
                    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
                    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
                    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
                    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
                    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
                    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
                  ];
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
                    headers = {
                      STSSeconds = 315360000;
                      STSPreload = true;
                      customFrameOptionsValue = "sameorigin";
                      contentTypeNosniff = true;
                      browserXSSFilter = true;
                      contentSecurityPolicy = "frame-ancestors 'self' https://*.nerdworks.de";
                      referrerPolicy = "no-referrer";
                    };
                  } // lib.optionalAttrs (svc.auth != {}) { auth = svc.auth; };
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

            # "Traefik will only try to generate a Let's encrypt certificate (thanks to HTTP-01 challenge) if the domain cannot be checked by the provided certificates."
            # From: https://docs.traefik.io/v1.7/user-guide/examples/#onhostrule-option-and-provided-certificates-with-http-challenge
            acme = {
              email = "elo-lenc@nerdworks.de";
              storage = "/var/lib/traefik/acme.json";
              entryPoint = "https";
              acmeLogging = true;
              onHostRule = true;
              httpChallenge.entryPoint = "http";
            };
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
