{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;

  accent = "1a66ff"; # blue

  # structure like in alacritty
  colors = {
    black = {
      # from https://github.com/jan-warchol/selenized/blob/master/terminals/alacritty/selenized-black.yml
      primary = {
        background = "#000000";
        foreground = "#ffffff";
        contrast = "#151515"; # added
        accent = "#${accent}";
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

    white = {
      # https://github.com/jan-warchol/selenized/blob/master/terminals/alacritty/selenized-white.yml
      primary = {
        background = "#ffffff";
        foreground = "#474747";
        contrast = "#eeeeee"; # added
        accent = "#${accent}";
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
  }.${cfg.theme};
  font = "SauceCodePro Nerd Font";

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
  }.${cfg.theme};

  swayColors = {
    black =
      let
        black = "#252525";
        blue = "#368aeb";
        cyan = "#3fc5b7";
        violet = "#a580e2";
        fg = "#b9b9b9";
        white = "#777777";
        yellow = "#dbb32d";
        orange = "#e67f43";
      in
      {
        background = colors.primary.background;
        focused = {
          border = colors.primary.accent;
          background = colors.primary.accent;
          text = black;
          indicator = blue;
          childBorder = colors.primary.accent;
        };
        focusedInactive = {
          border = cyan;
          background = cyan;
          text = black;
          indicator = violet;
          childBorder = cyan;
        };
        unfocused = {
          border = black;
          background = black;
          text = fg;
          indicator = white;
          childBorder = black;
        };
        urgent = {
          border = yellow;
          background = yellow;
          text = black;
          indicator = orange;
          childBorder = yellow;
        };
      };

    white = {
      background = colors.primary.background;
      focused = { background = "#285577"; border = colors.primary.accent; childBorder = "#285577"; indicator = "#2e9ef4"; text = "#ffffff"; };
    };
  }.${cfg.theme};
in
{
  config = mkIf cfg.enable {

    ptsd.desktop = {
      waybar = {
        bgColor = colors.primary.background;
        fgColor = colors.primary.foreground;
        contrastColor = colors.primary.contrast;
        accentColor = colors.primary.accent;
      };
    };

    # programs.fish.interactiveShellInit = ''
    #   set --global hydro_color_prompt ${accent};
    # '';

    home-manager.users.mainUser = { config, nixosConfig, pkgs, ... }:
      {
        home.sessionVariables = {
          # https://github.com/jarun/nnn/wiki/Usage#configuration
          NNN_FCOLORS = "c1e2272e006033f7c6d6abc4";
          BEMENU_OPTS = "--fn \\\"${font} ${toString nixosConfig.ptsd.desktop.fontSize}\\\" --nb ${colors.primary.background} --nf ${colors.primary.foreground} --hb ${colors.primary.contrast} --hf ${colors.primary.accent} --tb ${colors.primary.contrast} --tf ${colors.primary.accent}";
        };
        programs.foot.settings = footCfg;
        ptsd.firefox.extraExtensions = mkIf (cfg.theme == "black") [ pkgs.ptsd-firefoxAddons.darkreader ];
        programs.alacritty.settings.colors = colors;

        wayland.windowManager.sway = {
          config.colors = swayColors;
          #config.output."*".bg = "/sync/Pocket/P1080645.jpg fill";
          config.output."*".bg = "${colors.primary.background} solid_color";
        };
        gtk = {
          theme = {
            name = {
              black = "Adwaita-dark";
              white = "Adwaita";
            }.${cfg.theme};
            package = pkgs.gnome-themes-standard;
          };
        };

        programs.vscode.userSettings."workbench.colorTheme" = {
          black = "Default High Contrast";
          white = "Visual Studio Light";
        }.${cfg.theme};
      };
  };
}
