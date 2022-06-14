{ config, lib, pkgs, ... }:

let
  footCfg = {
    # https://codeberg.org/dnkl/foot/src/branch/master/themes/selenized-black
    black = {
      cursor.color = "181818 56d8c9";
      colors = {
        background = "181818";
        foreground = "b9b9b9";

        regular0 = "252525";
        regular1 = "ed4a46";
        regular2 = "70b433";
        regular3 = "dbb32d";
        regular4 = "368aeb";
        regular5 = "eb6eb7";
        regular6 = "3fc5b7";
        regular7 = "777777";

        bright0 = "3b3b3b";
        bright1 = "ff5e56";
        bright2 = "83c746";
        bright3 = "efc541";
        bright4 = "4f9cfe";
        bright5 = "ff81ca";
        bright6 = "56d8c9";
        bright7 = "dedede";
      };
    };

    # https://codeberg.org/dnkl/foot/src/branch/master/themes/selenized-white
    white = {
      cursor.color = "ffffff 009a8a";
      colors = {
        background = "ffffff";
        foreground = "474747";

        regular0 = "ebebeb";
        regular1 = "d6000c";
        regular2 = "1d9700";
        regular3 = "c49700";
        regular4 = "0064e4";
        regular5 = "dd0f9d";
        regular6 = "00ad9c";
        regular7 = "878787";

        bright0 = "cdcdcd";
        bright1 = "bf0000";
        bright2 = "008400";
        bright3 = "af8500";
        bright4 = "0054cf";
        bright5 = "c7008b";
        bright6 = "009a8a";
        bright7 = "282828";
      };
    };
  }.black;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = lib.mkDefault "Spleen:size=${toString 18}";
        dpi-aware = lib.mkDefault "no";
      };
      scrollback.lines = 50000;
    } // footCfg;
  };
}
