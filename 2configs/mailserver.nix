{ config, lib, pkgs, ... }:

{
  imports = [
    (
      builtins.fetchTarball {
        url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.3.0/nixos-mailserver-v2.3.0.tar.gz";
        sha256 = "0lpz08qviccvpfws2nm83n7m2r8add2wvfg9bljx9yxx8107r919";
      }
    )
  ];

  mailserver = {
    enable = true;
    fqdn = "htz2.host.nerdworks.de"; # has reverse DNS
    domains = [ "nerdworks.de" "nerd-works.de" ];

    loginAccounts = {};

    certificateScheme = 1;
    certificateFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
    keyFile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";

    backup.enable = true; # backup via rsnapshot

    virusScanning = false;
  };

}
