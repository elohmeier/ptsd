{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {};
  domain = "ws1.host.nerdworks.de";
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
    config = {
      domain = "https://${domain}";
      signupsAllowed = true;
      rocketAddress = "127.0.0.1"; # listen address
      rocketPort = toString config.ptsd.nwtraefik.ports.bitwarden; # listen port
      rocketLog = "critical";
    };
  };

  ptsd.nwtraefik = {
    services = [
      {
        name = "bitwarden";
        rule = "Host:${domain}";
      }
    ];
  };
}
