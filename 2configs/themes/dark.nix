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
    bemenuArgs = "--fn '${font}' --nb '${colors.primary.background}' --nf '${colors.primary.foreground}' --hb '${colors.primary.contrast}' --hf '${colors.primary.accent}' --tb '${colors.primary.contrast}' --tf '${colors.primary.accent}'";
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
