{ config, lib, pkgs, ... }:
let
  desktopSecrets = import <secrets-shared/desktop.nix>;
  todoistSecrets = import <secrets/todoist.nix>;
in
{
  imports = [
    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  ptsd.sway = {
    enable = true;
  };

  ptsd.nwi3status = {
    enable = true;
    openweathermapApiKey = desktopSecrets.openweathermapApiKey;
  };
}
