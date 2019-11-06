{ config, pkgs, ...}:
with import <ptsd/lib>;

let
  shellAliases = import ./aliases.nix;
in
{
  programs.zsh = {
    enable = true;

    initExtra = ''
      echo "Hello from PTSD"
    '';

    shellAliases = shellAliases;
  };
}
