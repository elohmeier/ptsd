{ config, lib, pkgs, ... }:

{
  imports =
    [
      <ptsd>
      <ptsd/2configs>
      <ptsd/2configs/nwhost-mini.nix>
      <secrets-shared/nwsecrets.nix>


      <ptsd/2configs/cli-tools.nix>

      #<ptsd/2configs/google-protected-web.nix>
    ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "htz3";
    interfaces.ens3 = {
      useDHCP = true;
      ipv6 = {
        addresses = [ { address = "2a01:4f8:c0c:5dac::1"; prefixLength = 64; } ];
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

  ptsd.nwtraefik.enable = true;

  ptsd.fraam-www = {
    enable = true;
    traefikFrontendRule = "Host:htz3.host.fraam.de";
  };

  ptsd.lego = {
    enable = true;
    domain = "${config.networking.hostName}.${config.networking.domain}";
    extraDomains = [
      "fraam.de"
      "dev.fraam.de"
      "www.fraam.de"
    ];
  };
}
