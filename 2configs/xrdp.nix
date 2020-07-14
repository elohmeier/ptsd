{ config, lib, pkgs, ... }:

{
  #users.groups.certs.members = [ "xrdp" ];

  ptsd.xrdp = {
    enable = true;
    # disabled to use the self-signed certificate, seems to work better
    #sslCert = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/cert.pem";
    #sslKey = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/key.pem";
    defaultWindowManager = "${pkgs.icewm}/bin/icewm";
  };
  environment.systemPackages = with pkgs; [ xterm xorg.xhost ];
  networking.firewall.interfaces.nwvpn.allowedTCPPorts = [ 3389 ];
  networking.firewall.interfaces.nwvpn.allowedUDPPorts = [ 3389 ];
}
