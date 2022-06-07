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
                config.ptsd.ports.prometheus-node
              ];
            };

            services.mysqlBackup = {
              enable = true;
              databases = [ "wordpress" ];
            };

            services.prometheus.exporters.node = {
              enable = true;
              listenAddress = cfg.containerAddress;
              port = config.ptsd.ports.prometheus-node;
              enabledCollectors = import ../../../2configs/prometheus/node_collectors.nix;
            };

            system.stateVersion = "21.11";
          };
      };

    ptsd.nwtraefik.services = [
      {
        name = "fraam-wordpress-auth";
        rule = "Host(`dev.fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.ports.fraam-wordpress}";
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
        url = "http://${cfg.containerAddress}:${toString config.ptsd.ports.fraam-wordpress}";
        entryPoints = [ "loopback4-https" ];
      }
      {
        name = "fraam-wwwstatic";
        rule = "Host(`www.fraam.de`) || Host(`fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.ports.fraam-wwwstatic}";
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
        url = "http://${cfg.containerAddress}:${toString config.ptsd.ports.prometheus-node}";
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

    environment.systemPackages = with pkgs; [
      (
        writers.writeDashBin "fraam-update-static-web" ''
          ROOT="''${1?must provide static root}"

          # fetch website
          ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de
          ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/karriere/
          ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/impressum/
          ${wget}/bin/wget --mirror --page-requisites --no-parent --directory-prefix="$ROOT" --no-host-directories https://dev.fraam.de/pentests/

          # remove absolute links
          ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\/\/dev.fraam.de\//\//g' {} +
          ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\\\/\\\/dev.fraam.de\\\//\\\//g' {} +
          ${findutils}/bin/find "$ROOT" -type f -exec ${gnused}/bin/sed -i 's/https:\/\/fraam.de\//\//g' {} +

          # fix missing slash in impressum link
          ${findutils}/bin/find "$ROOT" -type f -name "*.html" -exec ${gnused}/bin/sed -i 's/"\/impressum"/"\/impressum\/"/g' {} +

          # remove ?ver=... suffices from css/js files
          ${findutils}/bin/find "$ROOT" -type f -name "*?ver=*" | ${findutils}/bin/xargs -I % sh -c 'newname=$(echo % | ${gnused}/bin/sed "s/?ver=.*//"); ${coreutils}/bin/mv % $newname'
        ''
      )
    ];

    systemd.services.gowpcontactform = {
      description = "gowpcontactform";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''${pkgs.gowpcontactform}/bin/gowpcontactform \
                      -listen localhost:${toString config.ptsd.ports.gowpcontactform}'';
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
