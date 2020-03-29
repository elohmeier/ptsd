with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  # INFO: Remember there is an unused drive /dev/sda2 (/srv) installed.

  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/unbound.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu1";
    bridges.br0.interfaces = [
      "enp1s0"
      "enp2s0"
      "enp3s0"
    ];
    interfaces.br0 = {
      useDHCP = true;
    };

    hosts = {
      "192.168.178.10" = [ "nuc1.host.nerdworks.de" "nuc1" ]; # speed-up borg backup
    };
  };

  systemd.network.networks = {
    # 99-main will be removed in 20.03
    # effectively disable all-matching 99-main here
    "99-main" = {
      matchConfig = {
        MACAddress = "aa:bb:cc:dd:ee:ff";
      };
    };
  };
}
