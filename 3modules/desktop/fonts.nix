{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  fonts.fonts = with pkgs; lib.mkIf cfg.enable [
    # cozette
    # iosevka # pulls in i686-incompatible dependencies
    nerdfonts
    nwfonts
    # proggyfonts
    roboto
    roboto-slab
    # source-code-pro
    spleen
    win10fonts
  ];
}
