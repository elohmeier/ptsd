{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
  nets = universe.hosts."${config.networking.hostName}".nets;
in
{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/hardened.nix>
      <ptsd/2configs/matrix.nix>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/prometheus/node.nix>

      <secrets-shared/nwsecrets.nix>
    ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz2";
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = "2a01:4f8:c2c:b468::1"; prefixLength = 64; }];
      };
    };

    firewall = {
      # reduce noise coming from www if
      logRefusedConnections = false;

      interfaces.ens3 = {
        allowedTCPPorts = [ 53 ]; # acme-dns
        allowedUDPPorts = [ 53 ]; # acme-dns
      };
    };
  };

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  ptsd.nwtraefik = {
    enable = true;
    entryPoints = {
      "www4-http" = {
        address = "${nets.www.ip4.addr}:80";
      };
      "www4-https" = {
        address = "${nets.www.ip4.addr}:443";
      };
      "www6-http" = {
        address = "[${nets.www.ip6.addr}]:80";
      };
      "www6-https" = {
        address = "[${nets.www.ip6.addr}]:443";
      };
      "nwvpn-http" = {
        address = "${nets.nwvpn.ip4.addr}:80";
      };
      "nwvpn-https" = {
        address = "${nets.nwvpn.ip4.addr}:443";
      };

      # added for local tls monitoring
      "loopback4-https".address = "127.0.0.1:443";
    };
    certificates =
      let
        crt = domain: {
          certFile = "/var/lib/acme/${domain}/cert.pem";
          keyFile = "/var/lib/acme/${domain}/key.pem";
        };
      in
      [
        (crt "auth.nerdworks.de")
        (crt "mail.nerdworks.de")
        (crt "matrix.nerdworks.de")
      ];
    services = [
      {
        name = "acme-dns";
        rule = "Host(`auth.nerdworks.de`)";
        entryPoints = [ "www4-http" "www4-https" "www6-http" "www6-https" ];
      }
    ];
  };

  security.acme.certs =
    let
      envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
        ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
        ACME_DNS_API_BASE=https://auth.nerdworks.de
      '';
    in
    {
      "auth.nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        credentialsFile = envFile "auth.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "mail.nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        credentialsFile = envFile "mail.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "matrix.nerdworks.de" = {
        webroot = config.ptsd.nwacme.http.webroot;
        credentialsFile = envFile "matrix.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };
    };

  ptsd.nwacme = {
    enable = true;
    http.enable = true;
    hostCert = {
      enable = true;
      useHTTP = true;
    };
  };

  ptsd.acme-dns =
    let
      domain = "auth.nerdworks.de";
    in
    {

      enable = true;

      domain = "acme.nerdworks.de";
      nsname = domain;
      nsadmin = "elo-acme.nerdworks.de";

      records = [
        "${domain}. A ${nets.www.ip4.addr}"
        "acme.nerdworks.de. NS ${domain}"
      ];

      # use only ipv4 until
      # https://github.com/joohoi/acme-dns/issues/135 is fixed
      # TODO: route through traefik udp/tcp
      generalOptions = {
        listen = "${nets.www.ip4.addr}:53";
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
}
