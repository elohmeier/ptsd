{ config, lib, pkgs, ... }:
let
  domain = "mail.nerdworks.de";
in
{
  ptsd.secrets.files."radicale.htpasswd" = {
    path = "/run/radicale/radicale.htpasswd";
    dependants = [ "radicale.service" ];
  };

  ptsd.radicale = {
    enable = true;
    port = config.ptsd.nwtraefik.ports.radicale;
    htpasswd = config.ptsd.secrets.files."radicale.htpasswd".path;
  };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "radicale";
      rule = "Host:${domain}";
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" ];
      }
      {
        urls = [ "https://${domain}/.web" ];
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
      check process radicale matching "\.radicale-wrapped"
        start program = "${pkgs.systemd}/bin/systemctl start radicale"
        stop program = "${pkgs.systemd}/bin/systemctl stop radicale"

        if failed
          host ${domain}
          port 443
          certificate valid > 30 days
          protocol https
          request "/.web"
          then alert
    ''
  ];
}
