{ config, lib, pkgs, ... }:

let
  domain = "auth.nerdworks.de";

  # required Go 1.13 not in 19.09
  unstable = import <nixpkgs-unstable> {
    config.packageOverrides = import ../5pkgs unstable;
  };
in
{
  ptsd.acme-dns = {

    enable = true;
    package = unstable.acme-dns;

    domain = "acme.nerdworks.de";
    nsname = domain;
    nsadmin = "elo-acme.nerdworks.de";

    records = [
      "${domain}. A 116.203.211.215"
      "acme.nerdworks.de. NS ${domain}"
    ];

    # use only ipv4 until
    # https://github.com/joohoi/acme-dns/issues/135 is fixed
    generalOptions = {
      listen = "116.203.211.215:53";
      protocol = "both4";
    };

    apiOptions = {
      api_domain = domain;
      disable_registration = false;
      acme_cache_dir = "/var/lib/acme-dns/api-certs";
      corsorigins = [
        "*"
      ];
      use_header = true;
      header_name = "X-Forwarded-For";
      ip = "127.0.0.1";
      port = toString config.ptsd.nwtraefik.ports.acme-dns;
      tls = "none";
    };

  };

  # Chicken-Egg Problem - Don't use lego here!
  # (Missing) Certificate will be issued by traefik on it's own, 
  # see nwtraefik.nix.
  # ptsd.lego.extraDomains = [ domain ];

  ptsd.nwtraefik.services = [
    {
      name = "acme-dns";
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
          certificate valid > 30 days
          protocol https
          request "/update"
          status = 405
        then alert
    ''
  ];
}
