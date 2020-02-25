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
          content = "it works!"
        then alert
    ''
  ];
}
