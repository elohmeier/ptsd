{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.nwacme;
in
{
  options = {
    ptsd.nwacme = {
      enable = mkEnableOption "nwacme";
      enableHttpValidation = mkEnableOption "http-validation";
      entryPoints = mkOption {
        type = with types; listOf str;
        default = [ "www4-http" "www6-http" ];
      };
      webroot = mkOption {
        type = types.str;
        default = "/var/lib/acme/acme-challenges";
      };
    };
  };

  config = mkIf cfg.enable {

    services.nginx = mkIf cfg.enableHttpValidation {
      enable = true;
      virtualHosts = {
        "nwacme" = {
          listen = [
            {
              addr = "127.0.0.1";
              port = config.ptsd.nwtraefik.ports.nginx-nwacme;
            }
          ];

          locations."/.well-known/acme-challenge" = {
            root = "/var/lib/acme/acme-challenges";
          };
        };
      };
    };

    ptsd.nwtraefik.services = mkIf cfg.enableHttpValidation [
      {
        name = "nginx-nwacme";
        rule = "PathPrefix(`/.well-known/acme-challenge`)";
        entryPoints = cfg.entryPoints;
        priority = 9999; # high-priority for router
        tls = false;
      }
    ];

    users.groups.certs.members = mkIf cfg.enableHttpValidation [ config.services.nginx.user ];

  };
}
