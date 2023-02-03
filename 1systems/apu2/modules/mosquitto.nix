{ config, ... }:

{
  services.mosquitto = {
    enable = true;

    listeners = [{
      port = 1883;
      address = "192.168.168.41";
      settings.bind_interface = "bond0";
      users = {
        hass = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite homeassistant/#"
          ];
          passwordFile = config.ptsd.secrets.files."mosquitto-hass.passwd".path;
        };

        tasmota = {
          acl = [
            "readwrite cmnd/#"
            "readwrite stat/#"
            "readwrite tele/#"
            "readwrite homeassistant/#"
          ];
          passwordFile = config.ptsd.secrets.files."mosquitto-tasmota.passwd".path;
        };
      };
    }];
  };

  systemd.services.mosquitto.serviceConfig.SupplementaryGroups = "keys"; # ptsd secret access

  ptsd.secrets.files = {
    "mosquitto-hass.passwd" = { owner = "mosquitto"; };
    "mosquitto-tasmota.passwd" = { owner = "mosquitto"; };
  };
}
