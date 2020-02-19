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
    # metric is not used by systemd-networkd in 19.09,
    # so the route is configured below.
    #defaultGateway6 = {
    #  address = "fe80::1";
    #  metric = 42;
    #};
    interfaces.eth0 = {
      useDHCP = true;
      ipv6 = {
        addresses = [ { address = "2a01:4f8:c010:1adc::1"; prefixLength = 64; } ];
      };
    };
  };

  # prevents creation of the following route (`ip -6 route`):
  # default dev lo proto static metric 1024 pref medium
  systemd.network.networks."40-eth0".routes = [
    { routeConfig = { Gateway = "fe80::1"; }; }
  ];

  # when not null, for whatever reason this fails with:
  # cp: cannot stat '/var/src/secrets/initrd-ssh-key': No such file or directory
  # builder for '/nix/store/dwlv0grq7lmjayl1kk1jhsvgfz5flbwk-extra-utils.drv' failed with exit code 1
  boot.initrd.network.ssh.hostECDSAKey = lib.mkForce null;

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
