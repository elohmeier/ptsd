{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  fonts.fonts = with pkgs; lib.mkIf cfg.enable [
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
    nwfonts
    roboto
    roboto-slab
    spleen
    win10fonts
  ];
}
