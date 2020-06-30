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
        addresses = [ { address = "2a01:4f8:c010:1adc::1"; prefixLength = 64; } ];
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

  ptsd.wireguard.networks.nwvpn.server.enable = true;

  ptsd.nwtraefik = {
    enable = true;
    services = [
      {
        name = "nas1-public-www";
        rule = "Host:www.nerdworks.de;PathPrefix:/fpv";
        url = "http://${universe.hosts.nas1.nets.nwvpn.ip4.addr}:12345";
      }
    ];
  };

  # currently unused but configured domains
  ptsd.lego.extraDomains = [
    "gigs.nerdworks.de"
    "kb.nerdworks.de"
    "wiki.nerdworks.de"
    "www-dev.nerdworks.de"
  ];

  security.acme = let
    envFile = pkgs.writeText "lego-acme-dns.env" ''
      ACME_DNS_STORAGE_PATH=/var/lib/acme/luisarichter.de/acme-dns-store.json
      ACME_DNS_API_BASE=https://auth.nerdworks.de
    '';
  in
    {
      email = "elo-lenc@nerdworks.de";
      acceptTerms = true;
      certs = {
        "luisarichter.de" = {
          email = "office@luisarichter.de";
          extraDomains = { "www.luisarichter.de" = null; };
          dnsProvider = "acme-dns";
          credentialsFile = envFile;
        };
      };
    };
}
