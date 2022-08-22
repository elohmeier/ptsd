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
          #passwordFile = "/run/credentials/mosquitto.service/hass-passwd";
          passwordFile = config.ptsd.secrets.files."mosquitto-hass.passwd".path;
        };

        tasmota = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite tasmota/#"
          ];
          #passwordFile = "/run/credentials/mosquitto.service/tasmota-passwd";
          passwordFile = config.ptsd.secrets.files."mosquitto-tasmota.passwd".path;
        };
      };

      settings = {
        certfile = "/var/lib/acme/mqtt.nerdworks.de/fullchain.pem";
        keyfile = "/var/lib/acme/mqtt.nerdworks.de/key.pem";
      };
    }];
  };

  systemd.services.mosquitto.serviceConfig = {

    # not yet possible, see https://github.com/systemd/systemd/issues/19604
    #LoadCredential = [
    #  "hass-passwd:/var/src/secrets/mosquitto-hass.passwd"
    #  "tasmota-passwd:/var/src/secrets/mosquitto-tasmota.passwd"
    #];
    SupplementaryGroups = [
      "nginx" # acme cert access
      "keys" # ptsd secret access
    ];
  };

  ptsd.secrets.files = {
    "mosquitto-hass.passwd" = { owner = "mosquitto"; };
    "mosquitto-tasmota.passwd" = { owner = "mosquitto"; };
  };

  networking.firewall.interfaces.ens3.allowedTCPPorts = [ 8883 ];
}
