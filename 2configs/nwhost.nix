{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/3modules>
    <ptsd/2configs/nwhost-mini.nix>
  ];

  security.acme = let
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
          allowKeysForGroup = true;
          #dnsPropagationCheck = false;
        };
      };
    };

  ptsd.nwtraefik = let
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

  ptsd.nwtelegraf.enable = true;

  ptsd.nwmonit = {
    enable = true;
  };

  ptsd.nwbackup = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs."telegram.sh"
    pkgs.dnsutils
    pkgs.cryptsetup
    pkgs.tmux
  ];

  programs.mosh.enable = true;
  services.fail2ban.enable = true;

  system.fsPackages = [ pkgs.ntfs3g ];
}
