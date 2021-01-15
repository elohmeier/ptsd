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
      interface = mkOption {
        type = types.str;
      };
      tasmotaUsername = mkOption {
        type = types.str;
        default = "tasmota";
      };
      certDomain = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.${config.networking.domain}";
        description = "certificate beneath /var/lib/acme/";
      };
    };
  };

  # generate pw file using e.g. `nix-shell -p mosquitto --run "mosquitto_passwd -c -b pw tasmota $(pass mosquitto/dlrg/tasmota)"`
  config = mkIf cfg.enable {

    services.mosquitto = {
      enable = true;
      allowAnonymous = false;
      checkPasswords = true;
      ssl = {
        enable = true;
        cafile = "/etc/ssl/certs/ca-certificates.crt";
        certfile = "/var/lib/acme/${cfg.certDomain}/cert.pem";
        keyfile = "/var/lib/acme/${cfg.certDomain}/key.pem";
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
        "${cfg.tasmotaUsername}" = {
          acl = [
            "topic readwrite cmnd/#"
            "topic readwrite stat/#"
            "topic readwrite tele/#"
            "topic readwrite homeassistant/#"
          ];
          hashedPassword = secrets."${cfg.tasmotaUsername}";
        };
      };
      extraConf = ''
        bind_interface ${cfg.interface}
      '';
    };

    users.groups.certs.members = [ "mosquitto" ];

    systemd.services.mosquitto.serviceConfig = {
      CapabilityBoundingSet = "cap_net_bind_service";
      AmbientCapabilities = "cap_net_bind_service";
    };
  };
}
