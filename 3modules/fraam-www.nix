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

    containers.wpjail = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.containerAddress;
      bindMounts = {
        "/var/lib/mysql" = {
          hostPath = "${cfg.mysqlPath}";
          isReadOnly = false;
        };
        "/var/lib/mysql-backup" = {
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

      config =
        { config, pkgs, ... }:
        {
          imports = [
            <ptsd>
            <ptsd/2configs>
            <ptsd/2configs/fraam-wordpress.nix>
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

          systemd.services.mysql-backup = {
            description = "Backup WordPress MySQL database";
            wantedBy = [ "multi-user.target" ];
            requires = [ "mysql.service" ];
            script = ''
              ${pkgs.mariadb}/bin/mysqldump wordpress > /var/lib/mysql-backup/wordpress.sql
            '';
            serviceConfig = {
              Type = "simple";
              Restart = "on-failure";
              PrivateTmp = true;
              PrivateDevices = true;
              ProtectHome = true;
              ProtectSystem = "full";
            };
            startAt = "*-*-* 05:00:00";
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
        entryAddresses = [ "www4" "www6" ];
      }
      {
        # required for ../5pkgs/fraam-update-static-web access
        # host entry to 127.0.0.1 needs to be set
        name = "fraam-wordpress-local";
        rule = "Host(`dev.fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.fraam-wordpress}";
        entryAddresses = [ "loopback4" ];
      }
      {
        name = "fraam-wwwstatic";
        rule = "Host(`www.fraam.de`) || Host(`fraam.de`)";
        url = "http://${cfg.containerAddress}:${toString config.ptsd.nwtraefik.ports.fraam-wwwstatic}";
        entryAddresses = [ "www4" "www6" ];
      }
    ];

    ptsd.traefik-forward-auth = {
      enable = true;
      envFile = toString <secrets/traefik-forward-auth.env>;
    };

    system.activationScripts.initialize-fraam-www = stringAfter [ "users" "groups" ] ''
      mkdir -p ${cfg.mysqlPath}
      mkdir -p ${cfg.mysqlBackupPath}
      mkdir -p ${cfg.staticPath}
      mkdir -p ${cfg.wwwPath}
    '';

    environment.systemPackages = [ pkgs.fraam-update-static-web ];
  };
}
