{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/3modules/darwin>
  ];

  programs.zsh.enable = true;
}
