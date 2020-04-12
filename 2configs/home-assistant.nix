{ config, lib, pkgs, ... }:
let
  domain = "hass.services.nerdworks.de";
in
{
  services.home-assistant = {
    enable = true;

    package = pkgs.home-assistant.override {
      extraPackages = ps: with ps; [
        ps.hass-nabucasa # required for mobile app
        ps.influxdb
        ps.paho-mqtt
        (
          ps.buildPythonPackage rec {
            pname = "pyfritzhome";
            version = "0.4.2";
            doCheck = false;
            propagatedBuildInputs = [ ps.requests ];
            src = ps.fetchPypi {
              inherit pname version;
              sha256 = "0ncyv8svw0fhs01ijjkb1gcinb3jpyjvv9xw1bhnf4ri7b27g6ww";
            };
          }
        )
        ps.pyhomematic
        ps.pymetno
        ps.pynacl
        ps.pysonos
        ps.ssdp
        ps.zeroconf
      ];
    };
  };

  networking.firewall.allowedTCPPortRanges = [ { from = 30000; to = 50000; } ]; # for pyhomematic

  users.groups.lego.members = [ "hass" ];

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "home-assistant";
      rule = "Host:${domain}";
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" ];
      }
      {
        urls = [ "https://${domain}" ];
        response_string_match = "Home Assistant";
      }
    ];
    x509_cert = [
      {
        sources = [
          "https://${domain}:443"
        ];
      }
    ];
  };

  ptsd.nwmonit.extraConfig = [
    ''
      check host ${domain} with address ${domain}
        if failed
          port 80
          protocol http
          status = 302
        then alert

        if failed
          port 443
          protocol https and certificate valid > 30 days          
          content = "Home Assistant"
        then alert
    ''
  ];
}
