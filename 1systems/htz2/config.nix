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
      <ptsd/2configs/bitwarden.nix>
      <ptsd/2configs/mailserver.nix>
      <ptsd/2configs/matrix.nix>
      <ptsd/2configs/nwhost.nix>
      <ptsd/2configs/nwradicale.nix>
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
        addresses = [ { address = "2a01:4f8:c2c:b468::1"; prefixLength = 64; } ];
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

  ptsd.nwtraefik = {
    enable = true;
    acmeEntryAddress = "www4";
    entryAddresses = {
      www4 = universe.hosts."${config.networking.hostName}".nets.www.ip4.addr;
      www6 = "[${universe.hosts."${config.networking.hostName}".nets.www.ip6.addr}]";
      nwvpn = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;

      # added for local tls monitoring
      loopback4 = "127.0.0.1";
      loopback6 = "[::1]";
    };
  };
}
