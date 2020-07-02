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
      staticPath = mkOption {
        default = "/var/lib/fraam-www/static";
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
              <ptsd/2configs/wordpress.nix>
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

          };
    };

    ptsd.nwtraefik.services = [
      {
        name = "fraam-wordpress";
        rule = cfg.traefikFrontendRule;
        url = "http://${cfg.containerAddress}:80";
        # auth.forward = {
        #   address = "http://localhost:4181";
        #   authResponseHeaders = [ "X-Forwarded-User" ];
        # };
      }
      {
        name = "fraam-static";
        rule = "Host:htz3.host.fraam.de";
        url = "http://${cfg.containerAddress}:81";
      }
    ];

    ptsd.traefik-forward-auth = {
      enable = true;
      envFile = toString <secrets/traefik-forward-auth.env>;
    };

    system.activationScripts.initialize-fraam-www = stringAfter [ "users" "groups" ] ''
      mkdir -p ${cfg.mysqlPath}
      mkdir -p ${cfg.staticPath}
      mkdir -p ${cfg.wwwPath}
    '';

    environment.systemPackages = [ pkgs.fraam-update-static-web ];
  };
}
