{ config, lib, pkgs, ... }:
let
  desktopSecrets = import <secrets-shared/desktop.nix>;
  todoistSecrets = import <secrets/todoist.nix>;
in
{
  xsession.enable = true;

  imports = [
    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  ptsd.i3 = {
    enable = true;
    openweathermapApiKey = desktopSecrets.openweathermapApiKey;
    todoistApiKey = todoistSecrets.todoistApiKey;
  };
}
