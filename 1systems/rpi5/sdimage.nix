{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./physical.nix
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
  ];
}
