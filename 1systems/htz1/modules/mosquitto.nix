{ config, lib, pkgs, ... }:

{
  services.mosquitto = {
    enable = true;

    listeners = [{
      port = 8883;

      # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
      users = {
        hass = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite tasmota/#"
          ];
          passwordFile = "/var/src/secrets/mosquitto-hass.passwd";
        };

        tasmota = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite tasmota/#"
          ];
          passwordFile = "/var/src/secrets/mosquitto-tasmota.passwd";
        };
      };

      settings = {
        certfile = "/var/lib/acme/mqtt.nerdworks.de/fullchain.pem";
        keyfile = "/var/lib/acme/mqtt.nerdworks.de/key.pem";
      };
    }];
  };

  systemd.services.mosquitto.serviceConfig.SupplementaryGroups = "certs"; # acme cert access

  networking.firewall.interfaces.ens3.allowedTCPPorts = [ 8883 ];
}
