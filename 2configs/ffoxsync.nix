{ config, lib, pkgs, ... }:
let
  domain = "gigs.nerdworks.de";
in
{
  # identity.sync.tokenserver.uri
  # https://gigs.nerdworks.de/token/1.0/sync/1.5

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

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" ];
      }
      {
        urls = [ "https://${domain}" ];
        response_string_match = "it works!";
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
          certificate valid > 30 days
          protocol https
          content = "it works!"
        then alert
    ''
  ];
}
