{ config, lib, pkgs, ... }:
let
  domain = "hass.services.nerdworks.de";
in
{
  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant-variants.bs53;

    config = {

      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "::1" ];
      };
      prometheus = { };
      device_automation = { };
      config = { };
      frontend = { };
      history = { };
      logbook = { };
      map = { };
      mobile_app = { };
      person = { };
      recorder.db_url = "postgresql://@/home-assistant";
      sun = { };
      system_health = { };
      zeroconf = { };
      sonos.media_player.hosts = [ "192.168.178.57" "192.168.178.56" ];
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
      sensor = {
        platform = "dwd_weather_warnings";
        region_name = "Hansestadt Hamburg";
      };
      mqtt = {
        broker = "mqtt.nerdworks.de";
        port = 8883;
        username = "hass";
        password = "!secret mqtt_password";
        certificate = "/etc/ssl/certs/ca-certificates.crt";
        discovery = true;
      };
      fritzbox = { };
      brother = { };
      ipp = { };
      spotify = { };
      octoprint = { };
      automation = "!include automations.yaml";
    };
  };

  networking.firewall.interfaces.br0 = {
    allowedTCPPorts = [ 1400 ]; # for sonos
    allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic
  };

  ptsd.nwtraefik.services = [
    {
      name = "home-assistant";
      # rule = "Host(`${domain}`) || Host(`nas1.lan.nerdworks.de`)";
      # entryPoints = [ "nwvpn-http" "nwvpn-https" "lan-http" "lan-https" "loopback6-https" ];
      rule = "Host(`${domain}`)";
      entryPoints = [ "nwvpn-http" "nwvpn-https" "loopback6-https" ];
    }
  ];

  services.postgresql.ensureDatabases = [ "home-assistant" ];
  services.postgresql.ensureUsers = [
    {
      name = "hass";
      ensurePermissions."DATABASE \"home-assistant\"" = "ALL PRIVILEGES";
    }
  ];

  # services.nginx = {
  #   enable = true;
  #   virtualHosts = {
  #     # insecurely expose http api for sonos (which provides no secure tls ciphers)
  #     # also see https://community.home-assistant.io/t/solution-sonos-tts-with-nginx-ssl-reverse-proxy/58136
  #     "nas1.lan.nerdworks.de" = {
  #       listen = [
  #         {
  #           addr = "192.168.178.12";
  #           port = 8123;
  #         }
  #       ];
  #       locations."/" = {
  #         extraConfig = ''
  #           proxy_pass http://127.0.0.1:8123;
  #           proxy_set_header Host $host;
  #           proxy_http_version 1.1;
  #           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  #         '';
  #       };
  #     };
  #   };
  # };
  # networking.firewall.interfaces.br0.allowedTCPPorts = [ 8123 ];
}
