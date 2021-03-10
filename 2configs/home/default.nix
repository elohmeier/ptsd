{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };
}
