{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    unrar
  ];

  nixpkgs.config.allowUnfree = true; # required for unrar

  home.stateVersion = "20.09";
}
