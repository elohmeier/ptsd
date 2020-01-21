with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>

    <ptsd>

    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>

    <secrets-shared/nwsecrets.nix>
  ];

  ptsd.dlrgVpnClient = {
    enable = true;
    ip = "191.18.20.34";
  };

  ptsd.dockerHomeAssistant.enable = true;

  networking = {
    hostName = "apu2";
    bridges.br0.interfaces = [ "enp1s0" "enp2s0" "enp3s0" ];
  };
}
