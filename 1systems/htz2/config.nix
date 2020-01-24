{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost.nix>

      <secrets-shared/nwsecrets.nix>
    ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz2";
  };

  systemd.network = {
    enable = true;
    networks."99-main" = {
      DHCP = "ipv4";
      matchConfig = {
        MACAddress = "96:00:00:2e:6c:29";
      };

      address = [
        "2a01:4f8:c2c:b468::1/64"
      ];
      routes = [
        { routeConfig = { Gateway = "fe80::1"; }; }
      ];
    };
  };

  ptsd.nwtraefik = {
    enable = true;
    httpsPort = 1443;
    #logLevel = "DEBUG";
  };

  #ptsd.nwradicale = {
  #  enable = true;
  #};

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };

  # currently unused but configured domains
  ptsd.lego.extraDomains = [
    "mail.nerdworks.de"
  ];
}
