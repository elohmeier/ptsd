{ config, lib, pkgs, ... }:

let
  domain = "gigs.nerdworks.de";
in
{
  services.firefox.syncserver = {
    enable = true;
    listen.port = config.ptsd.nwtraefik.ports.ffoxsync;
    publicUrl = "https://${domain}/";
  };

  ptsd.lego.extraDomains = [
    domain
  ];

  ptsd.nwtraefik.services = [
    {
      name = "ffoxsync";
      rule = "Host:${domain}";
    }
  ];
}
