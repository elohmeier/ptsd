{ config, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <secrets-shared/nwsecrets.nix>
    #<ptsd/2configs/prometheus/node.nix>
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi4";
    interfaces.eth0.useDHCP = true;
  };

}
