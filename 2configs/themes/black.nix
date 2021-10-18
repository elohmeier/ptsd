{ config, lib, pkgs, ... }:


let
  # structure like in alacritty
  # from https://github.com/jan-warchol/selenized/blob/master/terminals/alacritty/selenized-black.yml
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

      # https://codeberg.org/dnkl/foot/src/branch/master/themes/selenized-black
      programs.foot.settings = {
        cursor.color = "";
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

      ptsd.firefox.extraExtensions = [ pkgs.ptsd-firefoxAddons.darkreader ];

      programs.alacritty.settings.colors = colors;

      wayland.windowManager.sway = {

        config.colors =
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

        extraConfig = ''
          output "*" bg /home/enno/Pocket/P1080645.jpg fill
        '';
      };
      gtk = {
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-standard;
        };
      };
    };

}
