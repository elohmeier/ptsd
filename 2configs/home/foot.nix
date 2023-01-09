{ config, lib, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkDefault "Spleen:size=${toString 12}";
        dpi-aware = lib.mkDefault "no";
      };
      scrollback.lines = 50000;
      cursor.color = with config.ptsd.style.colors; "${background} ${base0F}";

      colors = with config.ptsd.style.colors; {
        background = if background != "" then background else base00;
        foreground = if foreground != "" then foreground else base05;

        # Normal colors
        regular0 = base00; # Black, could also be base01
        regular1 = base08; # Red
        regular2 = base0B; # Green
        regular3 = base0A; # Yellow
        regular4 = base0D; # Blue
        regular5 = base0E; # Magenta
        regular6 = base0C; # Cyan
        regular7 = base05; # White

        # Bright colors
        bright0 = base03;
        bright1 = base09;
        bright2 = base01;
        bright3 = base02;
        bright4 = base04;
        bright5 = base06;
        bright6 = base0F;
        bright7 = base07;
      };
    };
  };
}
