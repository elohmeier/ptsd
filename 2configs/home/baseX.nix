{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home/file-manager.nix>
  ];

  home.keyboard = {
    layout = "de";
    variant = "nodeadkeys";
  };

  #ptsd.urxvt.enable = true;

  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Iosevka";
          #style = "Regular";
        };
        size = 8;
      };

      # Colors (Solarized Dark)
      colors = {
        # Default colors
        primary = {
          background = "#002b36"; # base03
          foreground = "#839496"; # base0
        };

        # Cursor colors
        cursor = {
          text = "#002b36"; # base03
          cursor = "#839496"; # base0
        };

        # Normal colors
        normal = {
          black = "#073642"; # base02
          red = "#dc322f"; # red
          green = "#859900"; # green
          yellow = "#b58900"; # yellow
          blue = "#268bd2"; # blue
          magenta = "#d33682"; # magenta
          cyan = "#2aa198"; # cyan
          white = "#eee8d5"; # base2
        };

        # Bright colors
        bright = {
          black = "#586e75"; # base01
          red = "#cb4b16"; # orange
          green = "#586e75"; # base01
          yellow = "#657b83"; # base00
          blue = "#839496"; # base0
          magenta = "#6c71c4"; # violet
          cyan = "#93a1a1"; # base1
          white = "#fdf6e3"; # base3
        };
      };
    };
  };

  home = {
    file.".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
  };

  home.packages = with pkgs;
    [
      xorg.xev
      xorg.xhost
      gnome3.file-roller
      zathura
      zathura-single
      caffeine
      lguf-brightness
      pcmanfm
      mpv
    ];

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  programs.firefox = {
    enable = true;
  };
}
