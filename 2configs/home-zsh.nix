{ config, pkgs, ... }:
with import <ptsd/lib>;

let
  shellAliases = import ./aliases.nix;
in
{
  home.packages = [
    pkgs.fzf
  ];

  programs.zsh = {
    enable = true;

    initExtra = ''
      source "$(${pkgs.fzf}/bin/fzf-share)/key-bindings.zsh"
    '';

    shellAliases = shellAliases;
  };
}
