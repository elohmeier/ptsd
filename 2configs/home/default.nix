{ config, lib, pkgs, ... }:

{
  imports = [
    ../../3modules/home
  ];

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };
}
