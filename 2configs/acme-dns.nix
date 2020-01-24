{ config, lib, pkgs, ... }:

{
  # use only ipv4 until
  # https://github.com/joohoi/acme-dns/issues/135 is fixed
  services.acme-dns = {
    enable = true;
    instances = {
      "ipv4" = {
        generalOptions = {
          listen = "116.203.211.215:53";
          protocol = "both4";
        };
        apiOptions = {
          ip = "116.203.211.215";
          autocert_port = "80";
          port = "443";
          tls = "letsencrypt";
        };
      };
    };
    domain = "acme.nerdworks.de";
    nsname = "auth.nerdworks.de";
    nsadmin = "elo-acme.nerdworks.de";
    records = [
      "auth.nerdworks.de. A 116.203.211.215"
      "acme.nerdworks.de. NS auth.nerdworks.de"
    ];
    apiOptions = {
      api_domain = "auth.nerdworks.de";
      disable_registration = false;
      acme_cache_dir = "/var/lib/acme-dns/api-certs";
      corsorigins = [
        "*"
      ];
      use_header = false;
      header_name = "X-Forwarded-For";
    };
  };
}
