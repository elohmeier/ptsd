with import <ptsd/lib>;
{ config, pkgs, ... }:
let
  bridgeIfs = [
    "enp1s0"
    "enp2s0"
    "enp3s0"
  ];
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  ptsd.wireguard.networks.dlrgvpn = {
    enable = true;
    ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
    natForwardIf = "br0";
  };

  ptsd.dockerHomeAssistant.enable = true;

  ptsd.nwbackup = {
    enable = true;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu2";
    bridges.br0.interfaces = bridgeIfs;
    interfaces.br0.useDHCP = true;
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
