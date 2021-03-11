{ config, lib, pkgs, ... }:
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/firefox.nix
    ../../2configs/home/gpg.nix
  ];
}
