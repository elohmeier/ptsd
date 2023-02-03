{ config, pkgs, ... }:

{
  programs.urxvt = {
    enable = true;
    extraConfig = with config.ptsd.style.colorsHex; {
      saveLines = 100000;

      urgentOnBell = true;

      perl-ext-common = "default,clipboard,font-size,url-select,keyboard-select";

      "url-select.underline" = true;
      "url-select.launcher" = "${pkgs.xdg-utils}/bin/xdg-open";
      "matcher.button" = 1; # allow left click on url

      #termName = "rxvt-unicode"; # fix bash backspace not working
      #termName = "xterm";

      inherit background;
      inherit foreground;
      cursorColor = base05;
      color0 = base00;
      color1 = base08;
      color2 = base0B;
      color3 = base0A;
      color4 = base0D;
      color5 = base0E;
      color6 = base0C;
      color7 = base05;
      color8 = base03;
      color9 = base09;
      color10 = base01;
      color11 = base02;
      color12 = base04;
      color13 = base06;
      color14 = base0F;
      color15 = base07;
    };
    fonts = [
      "xft:Spleen:size=18"
      "xft:Spleen:size=18:bold"
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
      "Home" = "\\033[1~";
      "KP_Home" = "\\033[1~";
      "End" = "\\033[4~";
      "KP_End" = "\\033[4~";

      "Shift-Control-V" = "perl:clipboard:paste";

      "M-u" = "perl:url-select:select_next";

      "M-Escape" = "perl:keyboard-select:activate";
      "M-s" = "perl:keyboard-select:search";
    };
  };

  home.packages = [ pkgs.xsel ]; # required by urxvt clipboard integration
}
