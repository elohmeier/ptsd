{ config, lib, pkgs, ... }:


let
  # structure like in alacritty
  colors = {
    # https://github.com/jan-warchol/selenized/blob/master/terminals/alacritty/selenized-white.yml
    primary = {
      background = "#ffffff";
      foreground = "#474747";
      contrast = "#151515"; # added
      accent = "#1a66ff"; # blue
    };
    normal = {
      black = "#ebebeb";
      red = "#d6000c";
      green = "#1d9700";
      yellow = "#c49700";
      blue = "#0064e4";
      magenta = "#dd0f9d";
      cyan = "#00ad9c";
      white = "#878787";
    };
    bright = {
      black = "#cdcdcd";
      red = "#bf0000";
      green = "#008400";
      yellow = "#af8500";
      blue = "#0054cf";
      magenta = "#c7008b";
      cyan = "#009a8a";
      white = "#282828";
    };
  };

  font = "SauceCodePro Nerd Font";
in
{
  ptsd.desktop = {
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
    BEMENU_OPTS = "--fn \\\"${font} ${toString config.ptsd.desktop.fontSize}\\\" --nb ${colors.primary.background} --nf ${colors.primary.foreground} --hb ${colors.primary.contrast} --hf ${colors.primary.accent} --tb ${colors.primary.contrast} --tf ${colors.primary.accent}";
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
