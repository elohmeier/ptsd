{ config, lib, pkgs, ... }:

let
  domain = "mail.nerdworks.de";
in
{
  ptsd.secrets.files."radicale.htpasswd" = {
    owner = "radicale";
    group-name = "radicale";
    mode = "0440";
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
