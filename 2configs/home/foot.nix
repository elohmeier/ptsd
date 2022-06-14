{ config, lib, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkDefault "Spleen:size=${toString 18}";
        dpi-aware = lib.mkDefault "no";
      };
      scrollback.lines = 50000;

      colors = with config.ptsd.style.colors; {
        background = base00;
        foreground = base05;

        regular0 = base00;
        regular1 = base08;
        regular2 = base0B;
        regular3 = base0A;
        regular4 = base0D;
        regular5 = base0E;
        regular6 = base0C;
        regular7 = base05;

        bright0 = base03;
        bright1 = base09;
        bright2 = base0F;
        bright3 = base0E;
        bright4 = base0C;
        bright5 = base01;
        bright6 = base0D;
        bright7 = base02;
      };
    };
  };
}
