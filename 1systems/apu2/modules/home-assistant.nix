{ config, lib, pkgs, ... }:

{
  ptsd.mosquitto = {
    enable = true;
    listeners = [{
      interface = "br0";
      address = "192.168.168.41";
    }];
  };

  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant-variants.dlrg;

    config = {
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";

      binary_sensor = [{
        platform = "template";
        sensors = {
          all_closed = {
            friendly_name = "Alles zu";
            value_template = ''
              {{ is_state("sensor.kuche_fenster_1_state", "closed") and
                 is_state("sensor.kuche_fenster_2_state", "closed") and
                 is_state("sensor.kuche_fenster_3_state", "closed") and
                 is_state("sensor.kuche_terrassentur_state", "closed") and
                 is_state("sensor.edv_raum_fenster_state", "closed") and
                 is_state("sensor.wc_herren_fenster_state", "closed") and
                 is_state("sensor.kl_schulungsraum_fenster_1_state", "closed") and
                 is_state("sensor.kl_schulungsraum_fenster_2_state", "closed") and
                 is_state("sensor.kl_schulungsraum_terrassentur_state", "closed") and
                 is_state("sensor.gr_schulungsraum_fenster_1_state", "closed") and
                 is_state("sensor.gr_schulungsraum_fenster_2_state", "closed") and
                 is_state("sensor.gr_schulungsraum_fenster_3_state", "closed") and
                 is_state("sensor.gr_schulungsraum_fenster_4_state", "closed") and
                 is_state("sensor.gr_schulungsraum_fenster_5_state", "closed") and
                 is_state("sensor.gr_schulungsraum_fenster_6_state", "closed") and
                 is_state("sensor.gr_schulungsraum_terrassentur_state", "closed") }}
            '';
          };

          lights_off = {
            friendly_name = "Alle Lichter aus";
            value_template = ''
              {{ is_state("switch.tasmota", "off") and
                 is_state("switch.tasmota_2", "off") and
                 is_state("switch.tasmota_3", "off") and
                 is_state("switch.tasmota_4", "off") and
                 is_state("switch.tasmota_5", "off") and
                 is_state("switch.tasmota_6", "off") and
                 is_state("switch.tasmota_7", "off") and
                 is_state("switch.tasmota_8", "off") and
                 is_state("switch.tasmota_9", "off") and
                 is_state("switch.tasmota_10", "off") }}
            '';
          };

          grs_meeting = {
            friendly_name = "Termin gr. Schulungsraum";
            value_template = ''
              {{ state_attr('calendar.schulungsraum_gross_ogos_smarthome', 'start_time') != None and
                 state_attr('calendar.schulungsraum_gross_ogos_smarthome', 'end_time') != None and
                 as_timestamp(state_attr('calendar.schulungsraum_gross_ogos_smarthome', 'start_time')) - as_timestamp(now()) < 7200 and
                 as_timestamp(state_attr('calendar.schulungsraum_gross_ogos_smarthome', 'end_time')) - as_timestamp(now()) > 0 }}'';
          };

          kls_meeting = {
            friendly_name = "Termin kl. Schulungsraum";
            value_template = ''
              {{ state_attr('calendar.schulungsraum_klein_ogos_smarthome', 'start_time') != None and
                 state_attr('calendar.schulungsraum_klein_ogos_smarthome', 'end_time') != None and
                 as_timestamp(state_attr('calendar.schulungsraum_klein_ogos_smarthome', 'start_time')) - as_timestamp(now()) < 7200 and
                 as_timestamp(state_attr('calendar.schulungsraum_klein_ogos_smarthome', 'end_time')) - as_timestamp(now()) > 0 }}'';
          };

          kueche_meeting = {
            friendly_name = "Termin Küche";
            value_template = ''
              {{ state_attr('calendar.kuche_ogos_smarthome', 'start_time') != None and
                 state_attr('calendar.kuche_ogos_smarthome', 'end_time') != None and
                 as_timestamp(state_attr('calendar.kuche_ogos_smarthome', 'start_time')) - as_timestamp(now()) < 7200 and
                 as_timestamp(state_attr('calendar.kuche_ogos_smarthome', 'end_time')) - as_timestamp(now()) > 0 }}'';
          };
        };
      }];

      config = { };

      calendar = [
        {
          platform = "caldav";
          url = "https://www.dlrg.cloud/remote.php/dav/public-calendars/Ff6RBg4nAHYpGZP3/?export";
        }
        {
          platform = "caldav";
          url = "https://www.dlrg.cloud/remote.php/dav/public-calendars/DnqLirynktYk8BC9/?export";
        }
        {
          platform = "caldav";
          url = "https://www.dlrg.cloud/remote.php/dav/public-calendars/HoXkggqRM6s9YfK6/?export";
        }
      ];

      frontend.themes.dlrg.primary-color = "#0072bc";

      history = { };

      homeassistant = {
        auth_providers = [{
          type = "homeassistant";
        }];
        latitude = "52.3019";
        longitude = "8.05097";
        name = "DLRG";
        time_zone = "Europe/Berlin";
        unit_system = "metric";
      };

      homematic =
        let
          host = "192.168.168.20";
          resolvenames = "json";
          username = "Admin";
          password = "!secret homematic_password";
        in
        {
          interfaces = {
            ip = {
              inherit host resolvenames username password; port = "2010";
            };
            rf = {
              inherit host resolvenames username password; port = "2001";
            };
          };
          hosts.ccu3 = { inherit host username password; };
        };

      http = {
        server_host = "127.0.0.1";
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
      logbook = { };
      recorder.purge_keep_days = 14;
      sensor = [{
        display_options = [ "date_time" ];
        platform = "time_date";
      }];

      mqtt = {
        broker = "127.0.0.1";
        port = "1883";
        username = "hass";
        password = "!secret mqtt_password";
        discovery = "true";
        discovery_prefix = "homeassistant";
      };

      prometheus = { };
      device_automation = { };
      mobile_app = { };
      system_health = { };
      fritzbox = { };
      met = { };
      ssdp = { };
    };
  };

  # compensate flaky home-assistant <-> homematic connection
  systemd.services.restart-home-assistant = {
    description = "Restart home-assistant every morning";
    startAt = "*-*-* 03:30:00";
    serviceConfig = {
      ExecStart = "${pkgs.systemd}/bin/systemctl restart home-assistant.service";
    };
  };

  ptsd.secrets.files."hass-secrets.yaml" = {
    path = "/var/lib/hass/secrets.yaml";
    dependants = [ "home-assistant.service" ];
    owner = "hass";
    group-name = "hass";
  };
}
