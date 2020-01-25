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
}
