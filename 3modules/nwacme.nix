{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.nwacme;
in
{
  options = {
    ptsd.nwacme = {
      enable = mkEnableOption "nwacme";
      hostCert = {
        enable = mkEnableOption "host-cert";
        useHTTP = mkOption {
          type = types.bool;
          default = false;
        };
      };
      http = mkOption {
        default = { };
        type = types.submodule {
          options = {
            enable = mkEnableOption "http-validation";
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
      };
    };
  };

  config = mkIf cfg.enable {

    assertions = [{
      assertion = cfg.hostCert.enable && cfg.hostCert.useHTTP -> cfg.http.enable;
      message = "ptsd.http has to be enabled to use HTTP-01 host certficate validation";
    }];

    services.nginx = mkIf cfg.http.enable {
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
            root = cfg.http.webroot;
          };
        };
      };
    };

    users.groups.certs.members = mkIf cfg.http.enable [ config.services.nginx.user ];

    security.acme =
      let
        envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
          ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
          ACME_DNS_API_BASE=https://auth.nerdworks.de
        '';
      in
      {
        email = lib.mkDefault "elo-lenc@nerdworks.de";
        acceptTerms = true;
        certs = mkIf cfg.hostCert.enable {
          "${config.networking.hostName}.${config.networking.domain}" = {
            webroot = mkIf cfg.hostCert.useHTTP cfg.http.webroot;
            dnsProvider = mkIf (!cfg.hostCert.useHTTP) "acme-dns";
            credentialsFile = mkIf (!cfg.hostCert.useHTTP) (envFile "${config.networking.hostName}.${config.networking.domain}");
            group = "certs";
            #dnsPropagationCheck = false;
          };
        };
      };

    ptsd.nwtraefik =
      let
        hostCert = {
          certFile = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/cert.pem";
          keyFile = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/key.pem";
        };
      in
      {
        certificates = mkIf cfg.hostCert.enable [
          hostCert
        ];
        defaultCertificate = mkIf cfg.hostCert.enable hostCert;
        services = mkIf cfg.http.enable [
          {
            name = "nginx-nwacme";
            rule = "PathPrefix(`/.well-known/acme-challenge`)";
            entryPoints = cfg.http.entryPoints;
            priority = 9999; # high-priority for router
            tls = false;
          }
        ];
      };
  };
}
