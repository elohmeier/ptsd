{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.home-assistant = {
    enable = true;
    configDir = "/nix/persistent/var/lib/hass";
    package =
      (pkgs.home-assistant.overrideAttrs (_: {
        doInstallCheck = false;
      })).override
        {
          extraComponents = [
            "dwd_weather_warnings"
            "esphome"
            "met"
            "radio_browser" # required by installation wizard
            "tasmota"
          ];
        };

    config = {
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";

      config = { };
      device_automation = { };
      homekit.filter.include_entity_globs = [
        "sensor.wemos_co2_mhz19b_carbondioxide"
        "light.*"
        "fan.*"
        "switch.weihnachtsbaum"
      ];
      mobile_app = { };
      mqtt = {
        fan = [
          {
            name = "Inventer";
            state_topic = "stat/tasmota_A8C8C4/fan_state";
            command_topic = "cmnd/tasmota_A8C8C4/fan_state";
            preset_modes = [
              "Wärmerückgewinnung"
              "Durchlüftung"
            ];
            preset_mode_state_topic = "stat/tasmota_A8C8C4/fan_preset_mode";
            preset_mode_command_topic = "cmnd/tasmota_A8C8C4/fan_preset_mode";
            percentage_command_topic = "cmnd/tasmota_A8C8C4/fan_percentage";
            percentage_state_topic = "stat/tasmota_A8C8C4/fan_percentage";
            speed_range_max = 4;
          }
        ];
      };
      prometheus = { };
      sonos = { };
      sun = { };
      system_health = { };

      homeassistant = {
        auth_providers = [ { type = "homeassistant"; } ];
        latitude = "53.568286";
        longitude = "9.971997";
        name = "Home";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
        external_url = "https://rpi4.pug-coho.ts.net";
        internal_url = "http://rpi4.fritz.box:8123";
      };

      frontend = { };

      http = {
        server_host = [
          "0.0.0.0"
          "::"
        ];
        server_port = config.ptsd.ports.home-assistant;
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
    };
  };

  systemd.services.home-assistant.preStart = with config.services.home-assistant; ''
    touch ${configDir}/{automations,scenes}.yaml
  '';

  systemd.services.home-assistant = {
    serviceConfig = {
      ExecStart = lib.mkForce "${config.services.home-assistant.package}/bin/hass --config '${config.services.home-assistant.configDir}' --log-file '/var/log/hass/home-assistant.log'";
      LogsDirectory = "hass";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      home-assistant = {
        forceSSL = true;
        listen = [
          {
            addr = config.ptsd.tailscale.ip;
            port = 443;
            ssl = true;
          }
        ];
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

  systemd.services.nginx = {
    # nginx should wait for tailscale
    wants = [ "tailscaled.service" ];

    serviceConfig = {
      # nginx should ensure that tailscales connection is initialized
      ExecStartPre = [ "+${pkgs.tailscale}/bin/tailscale up" ];

      SupplementaryGroups = [ "tailscale-cert" ];
    };
  };

  services.logrotate.enable = false;
}
