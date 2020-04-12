{ config, lib, pkgs, ... }:
let
  domain = "influxdb.services.nerdworks.de";
  kapacitorSecrets = import <secrets/kapacitor.nix>;
in
{
  services.influxdb = {
    enable = true;
    extraConfig = {
      http = {
        auth-enabled = true;
        bind-address = "127.0.0.1:${toString config.ptsd.nwtraefik.ports.influxdb}";
      };
    };
  };

  services.kapacitor =
    {
      enable = true;
      port = config.ptsd.nwtraefik.ports.kapacitor;
      bind = "127.0.0.1";
      defaultDatabase = {
        enable = true;
        url = "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.influxdb}";
        username = "kapacitor";
        password = kapacitorSecrets.influxPassword;
      };
    };

  systemd.services.kapacitor = {
    after = [ "influxdb" ];
    wants = [ "influxdb" ];
  };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "influxdb";
      rule = "Host:${domain}";
    }
    {
      name = "kapacitor";
      rule = "Host:${domain};Path:/kapacitor";
    }
  ];

  ptsd.nwtelegraf.inputs.influxdb = [
    {
      urls = [
        "http://127.0.0.1:${toString config.ptsd.nwtraefik.ports.influxdb}/debug/vars"
      ];
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" "https://${domain}/query" "https://${domain}/kapacitor" ];
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
          protocol https request "/debug/vars" and certificate valid > 30 days
        then alert

        if failed
          port 443
          certificate valid > 30 days
          protocol https
          request "/kapacitor"
          status = 404
          content = "error"
        then alert
    ''
  ];
}
