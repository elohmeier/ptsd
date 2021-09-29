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
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-standard;
        };
      };
    };

}
