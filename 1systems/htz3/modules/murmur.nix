{ config, lib, pkgs, ... }:

{
  environment.noXlibs = false;

  services.murmur = {
    enable = true;
    bandwidth = 130000; # bits per second
    allowHtml = false;
    password = "$MURMURD_PASSWORD";
    registerHostname = "voice.fraam.de";
    registerName = "fraam.de";
    registerUrl = "https://www.fraam.de";
    sendVersion = false;
    sslCert = "/var/lib/acme/voice.fraam.de/cert.pem";
    sslKey = "/var/lib/acme/voice.fraam.de/key.pem";
    users = 20;
    environmentFile = config.ptsd.secrets.files."murmur.env".path;
    extraConfig = ''
      opusthreshold=0
    '';
  };

  users.groups.certs.members = [ "murmur" ];

  networking.firewall.interfaces.ens3.allowedTCPPorts = [ config.services.murmur.port ];
  networking.firewall.interfaces.ens3.allowedUDPPorts = [ config.services.murmur.port ];

  ptsd.secrets.files."murmur.env".dependants = [ "murmur.service" ];
}
