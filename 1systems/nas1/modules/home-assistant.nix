{ config, lib, pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    package = (pkgs.home-assistant.overrideAttrs (_: { doInstallCheck = false; })).override { extraPackages = ps: [ ps.psycopg2 ]; };

    config = {

      apple_tv = { };
      automation = "!include automations.yaml";
      brother = { };
      config = { };
      device_automation = { };
      fritzbox = { };
      frontend = { };
      history = { };
      ipp = { };
      logbook = { };
      map = { };
      mobile_app = { };
      octoprint = { };
      person = { };
      prometheus = { };
      recorder.db_url = "postgresql://@/home-assistant";
      sensor = { platform = "dwd_weather_warnings"; region_name = "Hansestadt Hamburg"; };
      sonos.media_player.hosts = [ "192.168.178.57" "192.168.178.56" ];
      spotify = { };
      sun = { };
      system_health = { };
      tasmota = { };
      upnp = { };
      zeroconf = { };

      http = {
        server_host = [ "127.0.0.1" "::1" ];
        server_port = config.ptsd.ports.home-assistant;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };

      homematic =
        let
          host = "192.168.178.20";
          resolvenames = "json";
          username = "hass";
          password = "!secret homematic_password";
        in
        {
          interfaces = {
            ip = { inherit host resolvenames username password; port = 2010; };
            rf = { inherit host resolvenames username password; port = 2001; };
          };
          hosts.ccu3 = { inherit host username password; };
        };

      mqtt = {
        broker = "mqtt.nerdworks.de";
        port = 8883;
        username = "hass";
        password = "!secret mqtt_password";
        certificate = "/etc/ssl/certs/ca-certificates.crt";
        discovery = true;
      };
    };
  };

  networking.firewall.interfaces.br0 = {
    allowedTCPPorts = [ 1400 ]; # for sonos
    allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
  };

  services.postgresql.ensureDatabases = [ "home-assistant" ];
  services.postgresql.ensureUsers = [
    {
      name = "hass";
      ensurePermissions."DATABASE \"home-assistant\"" = "ALL PRIVILEGES";
    }
  ];
}
