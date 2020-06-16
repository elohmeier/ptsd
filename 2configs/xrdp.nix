{ config, lib, pkgs, ... }:

{
  #users.groups.lego.members = [ "xrdp" ];

  ptsd.xrdp = {
    enable = true;
    # disabled to use the self-signed certificate, seems to work better
    #sslCert = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
    #sslKey = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.key";
    defaultWindowManager = "${pkgs.icewm}/bin/icewm";
  };
  environment.systemPackages = with pkgs; [ xterm xorg.xhost ];
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ 3389 ];
  networking.firewall.interfaces.nwvpn.allowedUDPPorts = [ 3389 ];
}
