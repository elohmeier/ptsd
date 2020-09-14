{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.i3;
  i3_sway = import ./i3_sway_cfg.nix {
    inherit pkgs lib cfg config;
  };
in
{
  options.ptsd.i3 = i3_sway.options;

  config = mkIf cfg.enable {
    xsession = {
      windowManager.i3 =
        {
          enable = true;
          config = {
            modifier = i3_sway.modifier;
            keybindings = i3_sway.keybindings;
            modes = i3_sway.modes;
            startup = i3_sway.startup;
            window.commands = i3_sway.window_commands;
            fonts = i3_sway.fonts;
            bars = i3_sway.bars;
          };
          extraConfig = i3_sway.extraConfig;
        };

      pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ-AA";
      };
    };

    gtk = mkIf cfg.configureGtk i3_sway.gtk;

    programs.rofi = mkIf cfg.configureRofi i3_sway.rofi;

    home.packages = with pkgs; [
      i3lock # only needed for config testing / man pages
      # TODO: disabled for 20.09 until fix has landed in 20.09 (https://github.com/NixOS/nixpkgs/pull/97965)
      #libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE      
      brightnessctl
      flameshot
      nwlock
    ] ++ i3_sway.packages;

    home.sessionVariables = i3_sway.home_session_variables;

    ptsd.i3status-rust = {
      enable = true;
      config = i3_sway.i3status-rust_config;
    };

    # auto-hide the mouse cursor after inactivity
    services.unclutter = {
      enable = true;
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          geometry = "300x5-30+50";
          transparency = 10;
          frame_color = "#eceff1";
          font = "${cfg.fontMono} ${toString cfg.fontSize}";
        };

        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 5;
        };

        urgency_low.timeout = 1;
      };
    };
  };
}
