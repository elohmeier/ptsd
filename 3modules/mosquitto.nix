{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.mosquitto;
  secrets = import <secrets/mosquittoHashedPasswords.nix>;
in
{
  options = {
    ptsd.mosquitto = {
      enable = mkEnableOption "mosquitto";
      hostIP = mkOption {
        type = types.str;
      };
    };
  };

  # generate pw file using e.g. `nix-shell -p mosquitto --run "mosquitto_passwd -c -b pw tasmota $(pass mosquitto/dlrg/tasmota)"`
  config = mkIf cfg.enable {
    services.mosquitto = {
      enable = true;
      host = cfg.hostIP;
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
          hashedPassword = secrets.hass;
        };
        # see https://tasmota.github.io/docs/MQTT/#mqtt-topic-definition
        tasmota = {
          acl = [
            "topic readwrite cmnd/#"
            "topic readwrite stat/#"
            "topic readwrite tele/#"
            "topic readwrite homeassistant/#"
          ];
          hashedPassword = secrets.tasmota;
        };
      };
    };

    users.groups.certs.members = [ "mosquitto" ];
    networking.firewall.allowedTCPPorts = [ 1883 8883 ];
  };
}
