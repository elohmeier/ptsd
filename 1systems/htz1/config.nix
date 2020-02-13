{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/nerdworks-www.nix>
      <ptsd/2configs/nwgit.nix>
      <ptsd/2configs/ffoxsync.nix>
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
  };

  systemd.network = {
    enable = true;
    networks = {
      # 99-main seems to be removed in 20.03
      "99-main" = {
        DHCP = "ipv4";
        matchConfig = {
          MACAddress = "96:00:00:13:17:74";
        };
        address = [
          "2a01:4f8:c010:1adc::1/64"
        ];
        routes = [
          { routeConfig = { Gateway = "fe80::1"; }; }
        ];
      };
    };
  };

  ptsd.nwvpn-server = {
    enable = true;
  };

  ptsd.nwtraefik = {
    enable = true;
    #logLevel = "DEBUG";
  };

  # currently unused but configured domains
  ptsd.lego.extraDomains = [
    "kb.nerdworks.de"
    "wiki.nerdworks.de"
    "www-dev.nerdworks.de"
  ];
}
