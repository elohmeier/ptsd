{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.sway;
  i3_sway = import ./i3_sway_cfg.nix {
    inherit pkgs lib cfg config;
  };
in
{
  options.ptsd.sway = i3_sway.options;

  config = mkIf cfg.enable {
    # https://gitlab.com/chinstrap/gammastep

    programs.zsh.loginExtra = ''
      # If running from tty1 start sway
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec ${pkgs.sway}/bin/sway
      fi
    '';

    wayland.windowManager.sway = {
      enable = true;
      config =
        {
          modifier = i3_sway.modifier;
          keybindings = i3_sway.keybindings;
          modes = i3_sway.modes;
          #startup = i3_sway.startup;
          window.commands = i3_sway.window_commands;
          fonts = i3_sway.fonts;
          bars = i3_sway.bars;

          # use `swaymsg -t get_inputs`
          input = {
            "*" = {
              natural_scroll = "enabled";
              xkb_layout = "de";
              xkb_numlock = "enabled";
            };
          };
        };

      extraConfig = i3_sway.extraConfig;
    };

    gtk = mkIf cfg.configureGtk i3_sway.gtk;
    programs.rofi = mkIf cfg.configureRofi i3_sway.rofi;
    home.packages = with pkgs; [
      swaylock
    ] ++ i3_sway.packages;
    home.sessionVariables = i3_sway.home_session_variables;
  };

}
