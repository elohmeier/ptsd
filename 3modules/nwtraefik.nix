{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwtraefik;

  configFile = fileName: configOptions: pkgs.runCommand
    fileName
    {
      buildInputs = [ pkgs.remarshal ];
      preferLocalBuild = true;
    } ''
    remarshal -if json -of toml \
      < ${pkgs.writeText "config.json"
      (builtins.toJSON configOptions)} \
      > $out
  '';

  # middleware names
  mwSecurityHeaders = "security-headers";
  mwHttpsRedirect = "https-redirect";

  dynamicConfigOptions = {
    tls = {
      options.default = {
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
      };
      stores.default = lib.optionalAttrs (cfg.defaultCertificate.certFile != "" && cfg.defaultCertificate.keyFile != "") {
        defaultCertificate = {
          certFile = cfg.defaultCertificate.certFile;
          keyFile = cfg.defaultCertificate.keyFile;
        };
      };
      certificates =
        map
          (
            crt: {
              certFile = crt.certFile;
              keyFile = crt.keyFile;
              stores = [ "default" ];
            }
          )
          cfg.certificates;
    };

    http = {

      routers = builtins.listToAttrs (flatten
        (map
          (
            svc: (lib.optional (any (hasSuffix "-http") svc.entryPoints)
              {
                name = "${svc.name}-plain";
                value = {
                  entryPoints = filter (e: (hasSuffix "-http" e)) svc.entryPoints;
                  rule = svc.rule;
                  service = svc.name;
                  middlewares = [ mwSecurityHeaders ] ++ lib.optional svc.tls mwHttpsRedirect ++ svc.extraMiddlewares ++ lib.optional (svc.auth != { }) "${svc.name}-auth" ++ lib.optional (svc.stripPrefixes != [ ]) "${svc.name}-stripPrefix";
                  priority = svc.priority;
                };
              }
            ) ++ (lib.optional (svc.tls && (any (hasSuffix "-https") svc.entryPoints))
              {
                name = "${svc.name}-tls";
                value = {
                  entryPoints = filter (e: (hasSuffix "-https" e)) svc.entryPoints;
                  rule = svc.rule;
                  service = svc.name;
                  middlewares = [ mwSecurityHeaders ] ++ svc.extraMiddlewares ++ lib.optional (svc.auth != { }) "${svc.name}-auth" ++ lib.optional (svc.stripPrefixes != [ ]) "${svc.name}-stripPrefix";
                  priority = svc.priority;
                  tls = lib.optionalAttrs svc.letsencrypt {
                    certResolver = "letsencrypt";
                  };
                };
              }
            )
          )
          cfg.services)
      );

      middlewares = cfg.middlewares // (
        builtins.listToAttrs (
          map
            (
              svc: {
                name = "${svc.name}-auth";
                value = svc.auth;
              }
            )
            (filter (svc: svc.auth != { }) cfg.services)
        )
      ) // (
        builtins.listToAttrs (
          map
            (
              svc: {
                name = "${svc.name}-stripPrefix";
                value = { stripPrefix.prefixes = svc.stripPrefixes; };
              }
            )
            (filter (svc: svc.stripPrefixes != [ ]) cfg.services)
        )
      ) // {
        "${mwSecurityHeaders}".headers = {
          STSSeconds = 315360000;
          STSPreload = true;
          customFrameOptionsValue = "sameorigin";
          contentTypeNosniff = true;
          browserXSSFilter = true;
          contentSecurityPolicy = cfg.contentSecurityPolicy;
          referrerPolicy = "strict-origin";
        };

        "${mwHttpsRedirect}".redirectScheme = {
          permanent = true;
          scheme = "https";
        };
      };

      services = builtins.listToAttrs (
        map
          (
            svc: {
              name = svc.name;
              value = {
                loadBalancer = {
                  passHostHeader = svc.passHostHeader;
                  servers = [
                    { url = if (svc.url != "") then svc.url else "http://localhost:${toString config.ptsd.ports."${svc.name}"}"; }
                  ];
                };
              };
            }
          )
          cfg.services
      );

    };
  } // cfg.extraDynamicConfig;

  staticConfigOptions = {
    global = {
      checkNewVersion = false;
      sendAnonymousUsage = false;
    };
    providers.file.filename = configFile "traefik-dynamic-config.toml" dynamicConfigOptions;
    log.level = cfg.logLevel;
    accessLog = {
      filePath = "/var/log/traefik/access.log.json";
      bufferingSize = 100;
      format = "json";
      fields = {
        defaultMode = "keep";
        headers.defaultMode = "keep";
      };
    };
    entryPoints =
      (mapAttrs'
        (
          name: values:
            nameValuePair
              name
              ({
                address = values.address;
              } // lib.optionalAttrs (values.http != { }) {
                http = values.http;
              })
        )
        cfg.entryPoints) // optionalAttrs (config.ptsd.wireguard.networks.nwvpn.enable) {
        metrics = {
          address = "${config.ptsd.wireguard.networks.nwvpn.ip}:9101";
        };
      };
  } // optionalAttrs cfg.acmeEnabled {
    certificatesResolvers.letsencrypt.acme = {
      email = "elo-lenc@nerdworks.de";
      storage = "/var/lib/traefik/acme.json";
      httpChallenge.entryPoint = "${cfg.acmeEntryPoint}";
    };
  } // optionalAttrs (config.ptsd.wireguard.networks.nwvpn.enable) {
    metrics.prometheus.entryPoint = "metrics";
  };

  migrateLogs = pkgs.writers.writeDash "migrate-traefik-logs" ''
    if test -f "/var/lib/traefik/access.log"; then
      mkdir -p /var/log/traefik
      mv /var/lib/traefik/access.log /var/log/traefik/access.log
      echo "traefik access.log migrated"
    fi
  '';
in
{
  options = {
    ptsd.nwtraefik = {
      enable = mkEnableOption "nwtraefik";

      entryPoints = mkOption {
        description = "Entrypoints to listen on.";
        type = types.attrsOf (
          types.submodule (
            { config, ... }: {
              options = {
                name = mkOption {
                  type = types.strMatching ".+-(http|https)$";
                  default = config._module.args.name;
                };
                address = mkOption {
                  type = types.str;
                };
                http = mkOption {
                  type = types.attrs;
                  default = { };
                };
              };
            }
          )
        );
      };

      certificates = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              certFile = mkOption { type = types.str; };
              keyFile = mkOption { type = types.str; };
            };
          }
        );
        default = [ ];
      };

      defaultCertificate = mkOption {
        type = types.submodule {
          options = {
            certFile = mkOption { type = types.str; };
            keyFile = mkOption { type = types.str; };
          };
        };
        default = {
          certFile = "";
          keyFile = "";
        };
      };

      acmeEnabled = mkOption {
        default = false;
        type = types.bool;
      };

      acmeEntryPoint = mkOption {
        type = types.str;
        example = "www4-http";
      };

      logLevel = mkOption {
        type = types.str;
        default = "ERROR";
      };

      groups = mkOption {
        default = "";
        type = types.str;
        description = "supplementary groups to pass to the process";
      };

      services = mkOption {
        type = types.listOf (
          types.submodule {
            options = {
              name = mkOption { type = types.str; };
              entryPoints = mkOption { type = types.listOf (types.strMatching ".+-(http|https)$"); default = [ ]; };
              rule = mkOption { type = types.str; default = "Host(`*`)"; };
              auth = mkOption { type = types.attrs; default = { }; };
              url = mkOption { type = types.str; default = ""; };
              tls = mkOption { type = types.bool; default = true; };
              letsencrypt = mkOption { type = types.bool; default = false; };
              stripPrefixes = mkOption { type = types.listOf types.str; default = [ ]; };
              passHostHeader = mkOption { type = types.bool; default = true; };
              extraMiddlewares = mkOption { type = types.listOf types.str; default = [ ]; };
              priority = mkOption { type = types.int; default = 0; };
            };
          }
        );
        default = [ ];
        example = [
          {
            name = "nerdworkswww";
            rule = "Host(`www.nerdworks.de`)";
          }
        ];
      };

      middlewares = mkOption {
        default = { };
        type = types.attrs;
      };

      package = mkOption {
        default = pkgs.traefik;
        defaultText = "pkgs.traefik";
        type = types.package;
        description = "Traefik package to use.";
      };

      contentSecurityPolicy = mkOption {
        default = "frame-ancestors 'self' https://*.nerdworks.de";
        type = types.str;
      };

      extraDynamicConfig = mkOption {
        type = types.attrs;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.acmeEnabled -> hasAttr cfg.acmeEntryPoint cfg.entryPoints;
        message = "ptsd.nwtraefik.acmeEntryPoint \"${cfg.acmeEntryPoint}\" has to be defined in ptsd.nwtraefik.entryPoints";
      }
    ] ++ flatten (
      map
        (
          svc:
          map
            (
              entryPoint: {
                assertion = hasAttr entryPoint cfg.entryPoints;
                message = "ptsd.nwtraefik.services: entryPoint \"${entryPoint}\" used by service \"${svc.name}\" has to be defined in ptsd.nwtraefik.entryPoints";
              }
            )
            svc.entryPoints
        )
        cfg.services
    ) ++ (
      map
        (
          svc:
          {
            assertion = svc.entryPoints != [ ];
            message = "ptsd.nwtraefik.services: entrypoints have to be defined for service \"${svc.name}\"";
          }
        )
        cfg.services
    );

    # TODO: evaluate https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/systemd-confinement.nix

    systemd.services.traefik = {
      description = "Traefik web server";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/traefik --configfile=${configFile "traefik-static-conf.toml" staticConfigOptions}'';
        ExecStartPre = "+${migrateLogs}";
        DynamicUser = true;
        Type = "notify";
        WatchdogSec = "1s";
        Restart = "always";
        StartLimitBurst = 5;
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 256;
        LimitNOFILE = 1048576 * 2;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        StateDirectory = "traefik";
        LogsDirectory = "traefik";
        SupplementaryGroups = cfg.groups;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6"; # AF_UNIX required for watchdog
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
      };
      unitConfig = {
        StartLimitInterval = 86400;
      };
    };

    networking = {
      firewall = {
        allowedTCPPorts = [ 80 443 ];
      } // optionalAttrs (config.ptsd.wireguard.networks.nwvpn.enable) {
        interfaces.nwvpn.allowedTCPPorts = [ 9101 ]; # traefik metrics port
      };
    };

    ptsd.nwlogrotate.config = ''
      /var/log/traefik/*.log {
        daily
        rotate 7
        missingok
        notifempty
        compress
        dateext
        dateformat .%Y-%m-%d
        postrotate
          systemctl kill -s USR1 traefik.service
        endscript
      }

      /var/log/traefik/*.log.json {
        daily
        rotate 7
        missingok
        notifempty
        compress
        dateext
        dateformat .%Y-%m-%d
        postrotate
          systemctl kill -s USR1 traefik.service
        endscript
      }
    '';
  };
}
