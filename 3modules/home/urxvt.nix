{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.urxvt;
in
{
  options.ptsd.urxvt = {
    enable = mkEnableOption "urxvt terminal emulator";
    theme = mkOption {
      type = types.str;
      default = "solarized_dark";
    };
    font = mkOption {
      type = types.str;
      default = "Consolas";
    };
    fontSize = mkOption {
      type = types.int;
      default = 8;
      description = "the default font size to use";
    };
  };

  config = mkIf cfg.enable {

    programs.urxvt = let
      themes = {
        solarized_dark = {
          "background" = "#002b36";
          "foreground" = "#839496";
          "fadeColor" = "#002b36";
          "cursorColor" = "#93a1a1";
          "pointerColorBackground" = "#586e75";
          "pointerColorForeground" = "#93a1a1";
          "color0" = "#073642";
          "color8" = "#002b36";
          "color1" = "#dc322f";
          "color9" = "#cb4b16";
          "color2" = "#859900";
          "color10" = "#586e75";
          "color3" = "#b58900";
          "color11" = "#657b83";
          "color4" = "#268bd2";
          "color12" = "#839496";
          "color5" = "#d33682";
          "color13" = "#6c71c4";
          "color6" = "#2aa198";
          "color14" = "#93a1a1";
          "color7" = "#eee8d5";
          "color15" = "#fdf6e3";
        };
        solarized_light = {
          "background" = "#fdf6e3";
          "foreground" = "#657b83";
          "fadeColor" = "#fdf6e3";
          "cursorColor" = "#586e75";
          "pointerColorBackground" = "#93a1a1";
          "pointerColorForeground" = "#586e75";
          "color0" = "#073642";
          "color8" = "#002b36";
          "color1" = "#dc322f";
          "color9" = "#cb4b16";
          "color2" = "#859900";
          "color10" = "#586e75";
          "color3" = "#b58900";
          "color11" = "#657b83";
          "color4" = "#268bd2";
          "color12" = "#839496";
          "color5" = "#d33682";
          "color13" = "#6c71c4";
          "color6" = "#2aa198";
          "color14" = "#93a1a1";
          "color7" = "#eee8d5";
          "color15" = "#fdf6e3";
        };
      };
    in
      {
        enable = true;
        package = pkgs.rxvt_unicode-with-plugins;
        extraConfig = {
          saveLines = 100000;

          urgentOnBell = true;

          perl-ext-common = "default,clipboard,font-size,bell-command,url-select,keyboard-select";

          "url-select.underline" = true;
          "url-select.launcher" = "${pkgs.xdg_utils}/bin/xdg-open";
          "matcher.button" = 1; # allow left click on url

          bell-command = ''${pkgs.libnotify}/bin/notify-send "rxvt-unicode: bell!"''; # use `echo -ne '\007'` to test

          termName = "xterm-256color"; # fix bash backspace not working
        } // themes."${cfg.theme}";
        fonts = [
          "xft:${cfg.font}:size=${toString cfg.fontSize}"
          "xft:${cfg.font}:size=${toString cfg.fontSize}:bold"
        ];
        keybindings = {
          # font size
          "C-0x2b" = "font-size:increase"; # Ctrl+'+'
          "C-0x2d" = "font-size:decrease"; # Ctrl+'-'
          "C-0" = "font-size:reset";

          # Common Keybinds for Navigation
          "Shift-Up" = "command:\\033]720;1\\007"; # scroll one line higher
          "Shift-Down" = "command:\\033]721;1\\007"; # scroll one line lower
          "Control-Up" = "\\033[1;5A";
          "Control-Down" = "\\033[1;5B";
          "Control-Left" = "\\033[1;5D"; # jump to the previous word
          "Control-Right" = "\\033[1;5C"; # jump to the next word

          "Shift-Control-V" = "perl:clipboard:paste";

          "M-u" = "perl:url-select:select_next";

          "M-Escape" = "perl:keyboard-select:activate";
          "M-s" = "perl:keyboard-select:search";

          #"M-F1" = "command:\\033]710;xft:${cfg.font}:size=6\\007\\033]711;xft:${cfg.font}:size=6:bold\\007";
          #"M-F2" = "command:\\033]710;xft:${cfg.font}:size=${toString cfg.fontSize}\\007\\033]711;xft:${cfg.font}:size=${toString cfg.fontSize}:bold\\007";
          #"M-F3" = "command:\\033]710;xft:${cfg.font}:size=11\\007\\033]711;xft:${cfg.font}:size=11:bold\\007";
          #"M-F4" = "command:\\033]710;xft:${cfg.font}:size=25\\007\\033]711;xft:${cfg.font}:size=25:bold\\007";
          #"M-F5" = "command:\\033]710;xft:${cfg.font}:size=30\\007\\033]711;xft:${cfg.font}:size=30:bold\\007";
        };
      };

    home.packages = [ pkgs.xsel ]; # required by urxvt clipboard integration
  };
}
