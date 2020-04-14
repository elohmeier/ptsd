{ config, lib, pkgs, ... }:

{
  users.groups.lego.members = [ "xrdp" ];

  services.xrdp = {
    enable = true;
    sslCert = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
    sslKey = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.key";
    defaultWindowManager = "${pkgs.i3}/bin/i3";
  };
  environment.systemPackages = [ pkgs.xterm pkgs.i3 ];
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
}
