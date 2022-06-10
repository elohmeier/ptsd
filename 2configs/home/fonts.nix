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
}
