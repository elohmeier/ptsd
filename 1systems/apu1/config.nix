with import <ptsd/lib>;
{ config, pkgs, ... }:

let
  bridgeIfs = [
    "enp1s0"
    "enp2s0"
    "enp3s0"
  ];
in
{
  # INFO: Remember there is an unused drive /dev/sda2 (/srv) installed.

  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/bs53lan.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/unbound.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu1";
    bridges.br0.interfaces = bridgeIfs;
    interfaces.br0 = {
      useDHCP = true;
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
  } // builtins.listToAttrs (
    map (
      brName: {
        name = "40-${brName}";
        value = {
          networkConfig = {
            ConfigureWithoutCarrier = true;
          };
        };
      }
    ) bridgeIfs
  );
}
