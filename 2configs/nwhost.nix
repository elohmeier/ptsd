{ config, lib, pkgs, ... }:

let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/3modules>
  ];

  nix.gc.automatic = true;
  system.stateVersion = "19.09";

  services.timesyncd = {
    enable = true;
    servers = [
      "0.de.pool.ntp.org"
      "1.de.pool.ntp.org"
      "2.de.pool.ntp.org"
      "3.de.pool.ntp.org"
    ];
  };

  networking.domain = "host.nerdworks.de";

  networking.hosts = {
    "127.0.0.1" = [ "${config.networking.hostName}.${config.networking.domain}" "${config.networking.hostName}" ];
    "::1" = [ "${config.networking.hostName}.${config.networking.domain}" "${config.networking.hostName}" ];
  };

  ptsd.lego = {
    enable = true;
    domain = "${config.networking.hostName}.${config.networking.domain}";
  };

  ptsd.nwtelegraf.enable = true;

  ptsd.nwmonit = {
    enable = true;
  };

  ptsd.nwvpn = {
    enable = true;
    ip = universe.nwvpn."${config.networking.hostName}".ip;
  };

  ptsd.nwbackup = {
    enable = true;
  };

  environment.systemPackages = [
    (pkgs.callPackage ../5pkgs/telegram.sh {})
  ];
}
