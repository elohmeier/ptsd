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
      certfile = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/cert.pem";
      keyfile = "/var/lib/acme/${config.networking.hostName}.${config.networking.domain}/key.pem";
    };
    users = {
      hass = {
        acl = [
          "topic readwrite stat/sonoff/#"
          "topic readwrite homeassistant/#"
          "topic readwrite tasmota/#"
        ];
      };
      sonoff = {
        acl = [
          "topic readwrite stat/sonoff/#"
          "topic readwrite homeassistant/#"
          "topic readwrite tasmota/#"
        ];
      };
    };
  };

  users.groups.certs.members = [ "mosquitto" ];
  networking.firewall.allowedTCPPorts = [ 1883 8883 ];
}
