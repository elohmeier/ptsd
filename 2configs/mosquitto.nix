with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    {
      services.mosquitto.users =
        mapAttrs (_: h: { hashedPassword = h; })
          (import <secrets/mosquittoHashedPasswords.nix>);
    }
  ];

  services.mosquitto = {
    enable = true;
    host = "192.168.178.12";
    ssl = {
      enable = true;
      cafile = "/etc/ssl/certs/ca-certificates.crt";
      certfile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
      keyfile = "/var/lib/lego/certificates/${config.networking.hostName}.${config.networking.domain}.key";
    };
    users = {
      hass = {
        acl = [
          "topic readwrite stat/sonoff/#"
          "topic readwrite homeassistant/#"
        ];
      };
      sonoff = {
        acl = [
          "topic readwrite stat/sonoff/#"
          "topic readwrite homeassistant/#"
        ];
      };
    };
  };

  users.groups.lego.members = [ "mosquitto" ];
  networking.firewall.allowedTCPPorts = [ 1883 8883 ];
}
