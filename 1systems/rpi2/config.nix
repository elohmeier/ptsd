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

  networking.hostName = "rpi2";

  ptsd.dlrgVpnHost = {
    enable = true;
    ip = "191.18.21.35";
  };
}
