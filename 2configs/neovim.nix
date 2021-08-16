{ config, lib, pkgs, ... }:

{
  environment.variables.EDITOR = "nvim";

  environment.systemPackages = [
    pkgs.ptsd-neovim
  ];
}
