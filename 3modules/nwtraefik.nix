{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwtraefik;

  generateHttpEntrypoint = name: address:
    nameValuePair "${name}-http" {
      address = "${address}:${toString cfg.httpPort}";
      redirect.entryPoint = "${name}-https";
    };

  generateHttpsEntrypoint = name: address:
    nameValuePair "${name}-https" {
      address = "${address}:${toString cfg.httpsPort}";
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

  configOptions = {
    logLevel = cfg.logLevel;
    accessLog = {
      filePath = "/var/log/traefik/access.log";
      bufferingSize = 100;
    };
    # defaultEntryPoints = [ "https" "http" ];
    entryPoints = (mapAttrs' generateHttpEntrypoint cfg.entryAddresses) // (mapAttrs' generateHttpsEntrypoint cfg.entryAddresses);

    file = {};

    frontends = builtins.listToAttrs (
      map (
        svc: {
          name = svc.name;
          value = {
            entryPoints = flatten (map (name: [ "${name}-http" "${name}-https" ]) svc.entryAddresses);
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
  } // optionalAttrs cfg.acmeEnabled {
    # "Traefik will only try to generate a Let's encrypt certificate (thanks to HTTP-01 challenge) if the domain cannot be checked by the provided certificates."
    # From: https://docs.traefik.io/v1.7/user-guide/examples/#onhostrule-option-and-provided-certificates-with-http-challenge
    acme = {
      email = "elo-lenc@nerdworks.de";
      storage = "/var/lib/traefik/acme.json";
      entryPoint = "${cfg.acmeEntryAddress}-https";
      acmeLogging = true;
      onHostRule = true;
      httpChallenge.entryPoint = "${cfg.acmeEntryAddress}-http";
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

      entryAddresses = mkOption {
        description = "Addresses to listen on HTTP/HTTPS ports. Used for entrypoint generation.";
        type = types.attrsOf types.str;
        default = {
          any = "";
        };
        example = {
          ext4 = "123.123.123.123";
          ext6 = "2001:0db8:85a3:0000:0000:8a2e:0370:7334";
          vpn = "191.18.19.123";
        };
      };

      acmeEnabled = mkOption {
        default = true;
        type = types.bool;
      };

      acmeEntryAddress = mkOption {
        default = "any";
        type = types.str;
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
              entryAddresses = mkOption { type = types.listOf types.str; default = [ "any" ]; };
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
        acme-dns = 10001;
        bitwarden = 10002;
        dokuwiki = 10003;
        droneci = 10004;
        ffoxsync = 10005;
        grafana = 10006;
        home-assistant = 8123; # TODO: update yaml like in octoprint module
        influxdb = 10007;
        kapacitor = 10008;
        nerdworkswww = 10009;
        nextcloud = 10010;
        nginx-monica = 10011;
        nginx-htz3 = 10012;
        nwgit = 10013;
        octoprint = 10014;
        radicale = 10015;
        synapse = 10016;
      };
    }
    (
      mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.acmeEnabled -> hasAttr cfg.acmeEntryAddress cfg.entryAddresses;
            message = "ptsd.nwtraefik.acmeEntryAddress \"${cfg.acmeEntryAddress}\" has to be defined in ptsd.nwtraefik.entryAddresses";
          }
        ] ++ flatten (
          map (
            svc:
              map (
                entryAddress: {
                  assertion = hasAttr entryAddress cfg.entryAddresses;
                  message = "ptsd.nwtraefik.services: entryAddress \"${entryAddress}\" used by service \"${svc.name}\" has to be defined in ptsd.nwtraefik.entryAddresses";
                }
              ) svc.entryAddresses
          ) cfg.services
        );

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

        ptsd.nwlogrotate.configs = [
          ''
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
          ''
        ];

        # we assume that traefik deployments will have a configured entrypoint listening on the loopback interface
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
