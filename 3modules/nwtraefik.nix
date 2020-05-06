{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwtraefik;

  configOptions = {
    logLevel = cfg.logLevel;
    accessLog = {
      filePath = "/var/log/traefik/access.log";
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
        } // lib.optionalAttrs config.ptsd.lego.enable {
          certificates = [
            {
              certFile = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
              keyFile = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.key";
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
            servers.s1.url = if (svc.url != "") then svc.url else "http://localhost:${toString cfg.ports."${svc.name}"}";
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

  configFile =
    pkgs.runCommand "config.toml" {
      buildInputs = [ pkgs.remarshal ];
      preferLocalBuild = true;
    } ''
      remarshal -if json -of toml \
        < ${pkgs.writeText "config.json" (builtins.toJSON configOptions)} \
        > $out
    '';

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
              url = mkOption { type = types.str; default = ""; };
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

      package = mkOption {
        default = pkgs.traefik;
        defaultText = "pkgs.traefik";
        type = types.package;
        description = "Traefik package to use.";
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
        home-assistant = 8123;
        influxdb = 10078;
        kapacitor = 10079;
        nerdworkswww = 1080;
        nextcloud = 1082;
        nginx-monica = 10090;
        nginx-htz3 = 10091;
        nwgit = 10055;
        radicale = 5232;
      };
    }
    (
      mkIf cfg.enable {

        systemd.services.traefik = {
          description = "Traefik web server";
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = ''${cfg.package.bin}/bin/traefik --configfile=${configFile}'';
            ExecStartPre = "+${migrateLogs}";
            Type = "simple";
            DynamicUser = true;
            Restart = "on-failure";
            StartLimitInterval = 86400;
            StartLimitBurst = 5;
            AmbientCapabilities = "cap_net_bind_service";
            CapabilityBoundingSet = "cap_net_bind_service";
            NoNewPrivileges = true;
            LimitNPROC = 64;
            LimitNOFILE = 1048576;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectHome = true;
            ProtectSystem = "full";
            StateDirectory = "traefik";
            LogsDirectory = "traefik";
          } // lib.optionalAttrs (config.ptsd.lego.enable) {
            SupplementaryGroups = "lego";
          };
        };

        networking = {
          firewall = {
            allowedTCPPorts = [ cfg.httpPort cfg.httpsPort ];
          };
        };

        ptsd.nwtelegraf.inputs.x509_cert = [
          {
            sources = [
              "https://${config.networking.hostName}.${config.networking.domain}:${toString cfg.httpsPort}"
            ];
          }
        ];

      }
    )
  ];
}
