{ config, lib, pkgs, ... }:

{
  security.acme =
    let
      envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
        ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
        ACME_DNS_API_BASE=https://auth.nerdworks.de
      '';
    in
    {
      email = "elo-lenc@nerdworks.de";
      acceptTerms = true;
      certs = {
        "${config.networking.hostName}.${config.networking.domain}" = {
          dnsProvider = "acme-dns";
          credentialsFile = envFile "${config.networking.hostName}.${config.networking.domain}";
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
      certificates = [
        hostCert
      ];
      defaultCertificate = hostCert;
    };
}
