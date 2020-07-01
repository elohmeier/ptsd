{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  domain = "bitwarden.services.nerdworks.de";
in
{
  nixpkgs = {
    config.packageOverrides = pkgs: {
      bitwarden_rs = unstable.bitwarden_rs;
      bitwarden_rs-vault = unstable.bitwarden_rs-vault;
    };
  };

  services.bitwarden_rs = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      domain = "https://${domain}";
      signupsAllowed = true;
      rocketAddress = "127.0.0.1"; # listen address
      rocketPort = toString config.ptsd.nwtraefik.ports.bitwarden; # listen port
      rocketLog = "critical";
      databaseUrl = "postgresql:///bitwarden";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "bitwarden" ];
    ensureUsers = [
      {
        name = "bitwarden_rs"; # authenticated via Unix socket authentication
        ensurePermissions."DATABASE bitwarden" = "ALL PRIVILEGES";
      }
    ];
  };

  ptsd.lego.extraDomains = [ domain ];

  ptsd.nwtraefik = {
    services = [
      {
        name = "bitwarden";
        entryAddresses = [ "nwvpn" ];
        rule = "Host:${domain}";
      }
    ];
  };
}
