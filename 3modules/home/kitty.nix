{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.kitty;
in
{
  options.ptsd.kitty = {
    enable = mkEnableOption "kitty";
    fontSize = mkOption {
      type = types.int;
      default = 8;
    };
  };

  config = mkIf cfg.enable {

    programs.kitty = {
      enable = true;
      font.name = "Iosevka ${toString cfg.fontSize}";

      # solarized dark
      # source: https://github.com/kovidgoyal/kitty/issues/897#issuecomment-419220650
      settings = {
        background = "#002b36";
        foreground = "#839496";
        cursor = "#93a1a1";
        selection_background = "#81908f";
        selection_foreground = "#002831";
        color0 = "#073642";
        color1 = "#dc322f";
        color2 = "#859900";
        color3 = "#b58900";
        color4 = "#268bd2";
        color5 = "#d33682";
        color6 = "#2aa198";
        color7 = "#eee8d5";
        color9 = "#cb4b16";
        color8 = "#002b36";
        color10 = "#586e75";
        color11 = "#657b83";
        color12 = "#839496";
        color13 = "#6c71c4";
        color14 = "#93a1a1";
        color15 = "#fdf6e3";
      };
    };

    home.sessionVariables = {
      TERMINAL = "kitty";
    };

    programs.zsh.shellAliases.icat = "kitty +kitten icat";
  };
}
