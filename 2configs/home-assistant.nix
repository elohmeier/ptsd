{ config, lib, pkgs, ... }:
let
  domain = "hass.services.nerdworks.de";
in
{
  services.home-assistant = {
    enable = true;
    package = pkgs.nwhass;
  };

  networking.firewall.allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic

  ptsd.nwtraefik.services = [
    {
      name = "home-assistant";
      rule = "Host(`${domain}`) || Host(`nas1.lan.nerdworks.de`)";
      entryPoints = [ "nwvpn-http" "nwvpn-https" "lan-http" "lan-https" ];
    }
  ];

  services.postgresql.ensureDatabases = [ "home-assistant" ];
  services.postgresql.ensureUsers = [
    {
      name = "hass";
      ensurePermissions."DATABASE \"home-assistant\"" = "ALL PRIVILEGES";
    }
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      # insecurely expose http api for sonos (which provides no secure tls ciphers)
      # also see https://community.home-assistant.io/t/solution-sonos-tts-with-nginx-ssl-reverse-proxy/58136
      "nas1.lan.nerdworks.de" = {
        listen = [
          {
            addr = "192.168.178.12";
            port = 8123;
          }
        ];
        locations."/" = {
          extraConfig = ''
            proxy_pass http://127.0.0.1:8123;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };
  networking.firewall.interfaces.br0.allowedTCPPorts = [ 8123 ];

  # TODO: prometheus-migrate
  # ptsd.nwtelegraf.inputs = {
  #   http_response = [
  #     {
  #       urls = [ "http://${domain}" ];
  #     }
  #     {
  #       urls = [ "https://${domain}" ];
  #       response_string_match = "Home Assistant";
  #     }
  #   ];
  #   x509_cert = [
  #     {
  #       sources = [
  #         "https://${domain}:443"
  #       ];
  #     }
  #   ];
  # };

  ptsd.nwmonit.extraConfig = [
    ''
      check host ${domain} with address ${domain}
        if failed
          port 443
          protocol https and certificate valid > 30 days          
          content = "Home Assistant"
        then alert
    ''
  ];
}
