with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    {
      services.mosquitto.users =
        mapAttrs
          (_: h: { hashedPassword = h; })
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
          "topic readwrite cmnd/#"
          "topic readwrite stat/#"
          "topic readwrite tele/#"
          "topic readwrite homeassistant/#"
        ];
      };
      # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
      sonoff = {
        acl = [
          "topic readwrite cmnd/#"
          "topic readwrite stat/#"
          "topic readwrite tele/#"
          "topic readwrite homeassistant/#"
        ];
      };
    };
  };

  users.groups.certs.members = [ "mosquitto" ];
  networking.firewall.allowedTCPPorts = [ 1883 8883 ];
}
