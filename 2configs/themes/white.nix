{ config, lib, pkgs, ... }:


let
  # structure like in alacritty
  colors = {
    primary = {
      background = "#000000";
      foreground = "#ffffff";
      contrast = "#151515"; # added
      accent = "#1a66ff"; # blue
    };
    normal = {
      black = "#000000";
      red = "#ff7c4d";
      green = "#22ff00";
      yellow = "#ffcc00";
      blue = "#1a66ff";
      magenta = "#ff61df";
      cyan = "#00ffff";
      white = "#888888";
    };
  };
  font = "SauceCodePro Nerd Font";
in
{
  ptsd.desktop = {
    bemenuArgs = "--fn '${font} ${toString config.ptsd.desktop.fontSize}' --nb '${colors.primary.background}' --nf '${colors.primary.foreground}' --hb '${colors.primary.contrast}' --hf '${colors.primary.accent}' --tb '${colors.primary.contrast}' --tf '${colors.primary.accent}'";
    waybar = {
      bgColor = colors.primary.background;
      fgColor = colors.primary.foreground;
      contrastColor = colors.primary.contrast;
      accentColor = colors.primary.accent;
    };
  };

  environment.variables = {
    # https://github.com/jarun/nnn/wiki/Usage#configuration
    NNN_FCOLORS = "c1e2272e006033f7c6d6abc4";
  };

  home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
    {

      # https://codeberg.org/dnkl/foot/src/branch/master/themes/selenized-white
      programs.foot.settings = {
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

      programs.alacritty.settings.colors = colors;

      wayland.windowManager.sway = {

        config.colors = {
          background = colors.primary.background;
          focused = { background = "#285577"; border = colors.primary.accent; childBorder = "#285577"; indicator = "#2e9ef4"; text = "#ffffff"; };
        };

        extraConfig = ''
          output "*" bg /home/enno/Pocket/P1080645.jpg fill
        '';
      };
      gtk = {
        theme = {
          name = "Adwaita";
          package = pkgs.gnome-themes-standard;
        };
      };
    };

}
