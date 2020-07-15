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
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/prometheus/node.nix>
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

  systemd.network.networks = builtins.listToAttrs (
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
