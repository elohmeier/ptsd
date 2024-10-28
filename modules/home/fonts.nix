{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "SourceCodePro"
      ];
    })
    # nwfonts # TODO: fix src
    # win10fonts
    ibm-plex
    roboto
    roboto-slab
    spleen
  ];

  # see reg. mkForce: https://github.com/nix-community/home-manager/pull/3014
  fonts.fontconfig.enable = lib.mkForce pkgs.stdenv.isLinux;
}
