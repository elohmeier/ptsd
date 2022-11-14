{ config, lib, pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    configDir = "/mnt/hass";
    package = (pkgs.home-assistant.overrideAttrs (_: { doInstallCheck = false; })).override { extraPackages = ps: [ ps.psycopg2 ]; };

    config = {
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";

      # old format, see https://www.home-assistant.io/integrations/fan.mqtt/
      fan = [{
        name = "Inventer";
        platform = "mqtt";
        state_topic = "stat/tasmota_A8C8C4/fan_state";
        command_topic = "cmnd/tasmota_A8C8C4/fan_state";
        preset_modes = [ "Wärmerückgewinnung" "Durchlüftung" ];
        preset_mode_state_topic = "stat/tasmota_A8C8C4/fan_preset_mode";
        preset_mode_command_topic = "cmnd/tasmota_A8C8C4/fan_preset_mode";
        percentage_command_topic = "cmnd/tasmota_A8C8C4/fan_percentage";
        percentage_state_topic = "stat/tasmota_A8C8C4/fan_percentage";
        speed_range_max = 4;
      }];

      config = { };
      device_automation = { };
      history = { };
      homekit.filter.include_entity_globs = [ "sensor.wemos_co2_mhz19b_carbondioxide" "light.*" "fan.*" ];
      logbook = { };
      met = { };
      mobile_app = { };
      mqtt.certificate = "/etc/ssl/certs/ca-certificates.crt";
      prometheus = { };
      recorder.purge_keep_days = 14;
      sensor = { platform = "dwd_weather_warnings"; region_name = "Hansestadt Hamburg"; };
      sonos = { };
      sun = { };
      system_health = { };
      tasmota = { };

      homeassistant = {
        auth_providers = [{ type = "homeassistant"; }];
        latitude = "53.568286";
        longitude = "9.971997";
        name = "Home";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
      };

      http = {
        server_host = [ "127.0.0.1" "::1" ];
        server_port = config.ptsd.ports.home-assistant;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
    };
  };

  systemd.services.home-assistant.preStart = with config.services.home-assistant; ''
    touch ${configDir}/{automations,scenes}.yaml
  '';

  services.nginx = {
    enable = true;

    virtualHosts = {
      home-assistant = {
        forceSSL = true;
        listen = [{ addr = config.ptsd.tailscale.ip; port = config.ptsd.ports.home-assistant; ssl = true; }];
        sslCertificate = "/var/lib/tailscale-cert/${config.ptsd.tailscale.fqdn}.crt";
        sslCertificateKey = "/var/lib/tailscale-cert/${config.ptsd.tailscale.fqdn}.key";

        locations."/".extraConfig = ''
          proxy_http_version 1.1;
          proxy_pass http://127.0.0.1:8123;
          proxy_redirect http:// https://;
          proxy_set_header Connection $connection_upgrade;
          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
  };
}
