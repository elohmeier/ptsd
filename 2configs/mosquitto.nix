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
      certfile = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.crt";
      keyfile = "${config.ptsd.lego.home}/certificates/${config.networking.hostName}.${config.networking.domain}.key";
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

  users.groups.lego.members = [ "mosquitto" ];
  networking.firewall.allowedTCPPorts = [ 1883 8883 ];
}
