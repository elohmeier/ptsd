{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    # nwfonts # TODO: fix src
    roboto
    roboto-slab
    spleen
    win10fonts
  ];

  # see reg. mkForce: https://github.com/nix-community/home-manager/pull/3014
  fonts.fontconfig.enable = lib.mkForce pkgs.stdenv.isLinux;
}
