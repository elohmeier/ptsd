{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.fraam-www;
in
{
  options = {
    ptsd.fraam-www = {
      enable = mkEnableOption "fraam-www";
      extIf = mkOption {
        type = types.str;
        description = "external network interface container traffic will be NATed over";
      };
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
      mysqlBackupPath = mkOption {
        default = "/var/lib/fraam-www/mysql-backup";
      };
      staticPath = mkOption {
        default = "/var/lib/fraam-www/static";
      };
      wwwPath = mkOption {
        default = "/var/lib/fraam-www/www";
      };
    };
  };

  config = mkIf cfg.enable {

    networking = {
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = cfg.extIf;
      };
    };

    containers.wpjail =
      let
        hostConfig = config;
      in
      {
        autoStart = true;
        privateNetwork = true;
        hostAddress = cfg.hostAddress;
        localAddress = cfg.containerAddress;
        bindMounts = {
          "/var/lib/mysql" = {
            hostPath = "${cfg.mysqlPath}";
            isReadOnly = false;
          };
          "/var/backup/mysql" = {
            hostPath = "${cfg.mysqlBackupPath}";
            isReadOnly = false;
          };
          "/var/www/static" = {
            hostPath = "${cfg.staticPath}";
            isReadOnly = false;
          };
          "/var/www/wp" = {
            hostPath = "${cfg.wwwPath}";
            isReadOnly = false;
          };
        };
        ephemeral = true;

        config =
          { config, pkgs, ... }:
          {
            imports = [
              ../../../.
              ../../../2configs
              ./fraam-wordpress.nix
            ];

            nixpkgs.config.packageOverrides = hostConfig.nixpkgs.config.packageOverrides;

            boot.isContainer = true;

            networking = {
              useHostResolvConf = false;
              nameservers = [ "8.8.8.8" "8.8.4.4" ];
              useNetworkd = true;
              firewall.allowedTCPPorts = [
                config.ptsd.nwtraefik.ports.prometheus-node
              ];
            };

            time.timeZone = "Europe/Berlin";

            i18n = {
              defaultLocale = "de_DE.UTF-8";
              supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
            };

            services.mysqlBackup = {
              enable = true;
              databases = [ "wordpress" ];
            };

            services.prometheus.exporters.node = {
              enable = true;
              listenAddress = cfg.containerAddress;
              port = config.ptsd.nwtraefik.ports.prometheus-node;
              enabledCollectors = import ../../../2configs/prometheus/node_collectors.nix;
            };
          };
      };

    ptsd.nwtraefik.services = [
      {
        name = "fraam-wordpress-auth";
        rule = "Host(`dev.fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.fraam-wordpress}";
        auth.forwardAuth = {
          address = "http://localhost:4181";
          authResponseHeaders = [ "X-Forwarded-User" ];
        };
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
      {
        # required for ../5pkgs/fraam-update-static-web access
        # host entry to 127.0.0.1 needs to be set
        name = "fraam-wordpress-local";
        rule = "Host(`dev.fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.fraam-wordpress}";
        entryPoints = [ "loopback4-https" ];
      }
      {
        name = "fraam-wwwstatic";
        rule = "Host(`www.fraam.de`) || Host(`fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.fraam-wwwstatic}";
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
      {
        name = "gowpcontactform";
        rule = "PathPrefix(`/wp-json/contact-form-7/`) && (Host(`www.fraam.de`) || Host(`fraam.de`))";
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
      {
        name = "prometheus-node-wpjail";
        entryPoints = [ "nwvpn-prometheus-http" ];
        rule = "PathPrefix(`/wpjail/node`) && Host(`${config.ptsd.wireguard.networks.nwvpn.ip}`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.prometheus-node}";
        tls = false;
        extraMiddlewares = [ "prom-stripprefix" ];
      }
    ];

    ptsd.secrets.files."traefik-forward-auth.env" = { };

    ptsd.traefik-forward-auth = {
      enable = true;
      envFile = config.ptsd.secrets.files."traefik-forward-auth.env".path;
    };

    system.activationScripts.initialize-fraam-www = stringAfter [ "users" "groups" ] ''
      mkdir -p ${cfg.mysqlPath}
      mkdir -p ${cfg.mysqlBackupPath}
      mkdir -p ${cfg.staticPath}
      mkdir -p ${cfg.wwwPath}
    '';

    environment.systemPackages = [ pkgs.fraam-update-static-web ];

    systemd.services.gowpcontactform = {
      description = "gowpcontactform";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''${pkgs.gowpcontactform}/bin/gowpcontactform \
                      -listen localhost:${toString config.ptsd.nwtraefik.ports.gowpcontactform}'';
        DynamicUser = true;
        Restart = "on-failure";
        StartLimitBurst = 5;
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
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
  };
}
