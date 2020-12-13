{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/acme-dns.nix>
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

    # reduce noise coming from www if
    firewall.logRefusedConnections = false;
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
        address = "${universe.hosts."${config.networking.hostName}".nets.www.ip4.addr}:80";
        http.redirections.entryPoint = {
          to = "www4-https";
          scheme = "https";
          permanent = true;
        };
      };
      "www4-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.www.ip4.addr}:443";
      };
      "www6-http" = {
        address = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]:80";
        http.redirections.entryPoint = {
          to = "www6-https";
          scheme = "https";
          permanent = true;
        };
      };
      "www6-https" = {
        address = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]:443";
      };
      "nwvpn-http" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:80";
        http.redirections.entryPoint = {
          to = "nwvpn-https";
          scheme = "https";
          permanent = true;
        };
      };
      "nwvpn-https" = {
        address = "${universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr}:443";
      };

      # added for local tls monitoring
      "loopback4-https".address = "127.0.0.1:443";
    };
    acmeEnabled = true;
    acmeEntryPoint = "www4-http";
    certificates =
      let
        crt = domain: {
          certFile = "/var/lib/acme/${domain}/cert.pem";
          keyFile = "/var/lib/acme/${domain}/key.pem";
        };
      in
      [
        (crt "bitwarden.services.nerdworks.de")
        (crt "mail.nerdworks.de")
      ];
  };

  ptsd.nwbitwarden = {
    enable = true;
    domain = "bitwarden.services.nerdworks.de";
  };

  security.acme.certs =
    let
      envFile = domain: pkgs.writeText "lego-acme-dns-${domain}.env" ''
        ACME_DNS_STORAGE_PATH=/var/lib/acme/${domain}/acme-dns-store.json
        ACME_DNS_API_BASE=https://auth.nerdworks.de
      '';
    in
    {
      "bitwarden.services.nerdworks.de" = {
        dnsProvider = "acme-dns";
        credentialsFile = envFile "bitwarden.services.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "mail.nerdworks.de" = {
        dnsProvider = "acme-dns";
        credentialsFile = envFile "mail.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };
    };
}
