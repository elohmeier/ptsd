{ config, lib, pkgs, ... }:
let
  domain = "auth.nerdworks.de";
in
{
  ptsd.acme-dns = {

    enable = true;

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

  networking.firewall.interfaces.ens3 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  ptsd.nwtraefik.services = [
    {
      name = "acme-dns";
      rule = "Host(`${domain}`)";
      entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];

      # Chicken-Egg Problem - Don't use lego here for the certificate fetching!
      # (Missing) Certificate will be issued by traefik on it's own, 
      # see nwtraefik.nix.
      letsencrypt = true;
    }
  ];

  ptsd.nwtelegraf.inputs = {
    http_response = [
      {
        urls = [ "http://${domain}" "https://${domain}/update" ];
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
          port 443
          certificate valid > 30 days
          protocol https
          request "/update"
          status = 405
        then alert
    ''
  ];
}
