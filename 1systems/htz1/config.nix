{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/nerdworks-www.nix>
      <ptsd/2configs/nwgit.nix>
      <ptsd/2configs/drone-ci.nix>
      <ptsd/2configs/wdplaner.nix>
      <ptsd/2configs/prometheus/node.nix>

      # TODO: upgrade geoip update script
      # see https://blog.maxmind.com/2019/12/18/significant-changes-to-accessing-and-using-geolite2-databases/
      #<ptsd/2configs/nerdworks-www-stats.nix>

      <secrets-shared/nwsecrets.nix>
    ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz1";
    # metric is not used by systemd-networkd in 19.09,
    # so the route is configured below.
    #defaultGateway6 = {
    #  address = "fe80::1";
    #  metric = 42;
    #};
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [{ address = "2a01:4f8:c010:1adc::1"; prefixLength = 64; }];
      };
    };
  };

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-ens3".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  # when not null, for whatever reason this fails with:
  # cp: cannot stat '/var/src/secrets/initrd-ssh-key': No such file or directory
  # builder for '/nix/store/dwlv0grq7lmjayl1kk1jhsvgfz5flbwk-extra-utils.drv' failed with exit code 1
  boot.initrd.network.ssh.hostECDSAKey = lib.mkForce null;

  ptsd.wireguard.networks.nwvpn = {
    server.enable = true;
    routes = [
      { routeConfig = { Destination = "192.168.178.0/24"; }; }
    ];
  };

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
    };
    services = [
      {
        name = "nas1-public-www";
        rule = "Host(`www.nerdworks.de`) && PathPrefix(`/fpv`)";
        url = "http://${universe.hosts.nas1.nets.nwvpn.ip4.addr}:12345";
      }
    ];
    certificates =
      let
        crt = domain: {
          certFile = "/var/lib/acme/${domain}/cert.pem";
          keyFile = "/var/lib/acme/${domain}/key.pem";
        };
      in
      [
        (crt "nerdworks.de")
        (crt "ci.nerdworks.de")
        (crt "git.nerdworks.de")
        (crt "luisarichter.de")
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
      "nerdworks.de" = {
        extraDomainNames = [ "www.nerdworks.de" ];
        dnsProvider = "acme-dns";
        credentialsFile = envFile "nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "ci.nerdworks.de" = {
        dnsProvider = "acme-dns";
        credentialsFile = envFile "ci.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "git.nerdworks.de" = {
        dnsProvider = "acme-dns";
        credentialsFile = envFile "git.nerdworks.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };

      "luisarichter.de" = {
        email = "office@luisarichter.de";
        extraDomainNames = [ "www.luisarichter.de" ];
        dnsProvider = "acme-dns";
        credentialsFile = envFile "luisarichter.de";
        group = "certs";
        postRun = "systemctl restart traefik.service";
      };
    };
}
