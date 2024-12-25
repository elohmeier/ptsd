{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # nwfonts # TODO: fix src
    # win10fonts
    ibm-plex
    # nerdfonts.fira-code
    # nerdfonts.source-code-pro
    roboto
    roboto-slab
    spleen
  ];

  # see reg. mkForce: https://github.com/nix-community/home-manager/pull/3014
  fonts.fontconfig.enable = lib.mkForce pkgs.stdenv.isLinux;
}
