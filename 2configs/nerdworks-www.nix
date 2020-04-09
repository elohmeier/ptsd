{ config, lib, pkgs, ... }:
let
  mynginx = pkgs.nginx.override {
    modules = with pkgs.nginxModules; [ fancyindex ];
  };
in
{
  services.nginx = {
    enable = true;

    commonHttpConfig = ''
      charset UTF-8;
    '';

    virtualHosts = {

      "www.nerdworks.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.nwtraefik.ports.nerdworkswww;
          }
        ];
        root = "/var/www/nerdworks.de/prod-v2";
        locations."/dl/" = {
          alias = "/var/www/nerdworks.de/dl/";
          #extraConfig = ''
          #  fancyindex on;
          #  fancyindex_exact_size off;
          #'';
        };
      };

      "nerdworks.de" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = config.ptsd.nwtraefik.ports.nerdworkswww;
          }
        ];
        globalRedirect = "www.nerdworks.de";
      };

    };

    #package = mynginx;
  };

  ptsd.lego.extraDomains = [
    "nerdworks.de"
    "www.nerdworks.de"
  ];

  ptsd.nwtraefik.services = [
    {
      name = "nerdworkswww";
      rule = "Host:nerdworks.de,www.nerdworks.de";
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://www.nerdworks.de" "http://nerdworks.de" "https://nerdworks.de" ];
      }
      {
        urls = [ "https://www.nerdworks.de" ];
        response_string_match = "Nerdworks Hamburg unterstützt Unternehmen bei";
      }
    ];
    x509_cert = [
      {
        sources = [
          "https://nerdworks.de"
          "https://www.nerdworks.de"
        ];
      }
    ];
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check host www.nerdworks.de with address www.nerdworks.de
        if failed
          port 80
          protocol http
          status = 302
        then alert

        if failed
          port 443
          protocol https and certificate valid > 30 days
          content = "Nerdworks Hamburg unterstützt Unternehmen bei"
        then alert
    ''
  ];
}
