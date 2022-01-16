{ config, lib, pkgs, ... }:

{

  imports = [
    ../../2configs/home/fish.nix
  ];

  programs.mpv = {
    enable = true;
    bindings = {
      VOLUME_UP = "ignore";
      VOLUME_DOWN = "ignore";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      terminal = "${pkgs.foot}/bin/foot";
      modifier = "Mod1"; # Alt
      input =
        let
          repeat_delay = "200";
          repeat_rate = "15";
          xkb_file = "${pkgs.sxmo-utils}/share/sxmo/sway/xkb_mobile_normal_buttons";
        in
        {
          # repeat_delay how much time in milisec to consider it is hold pressed
          #    should be long enough to trigger simple click easily but
          #    should be short enough to trigger a repeat before the next threshold
          # repeat_rate then how much key per second should be triggered
          #    adapt it accordingly with the delay.
          #    prefer a lower but enough value
          # This is enough for 4 multikeys long presses


          ### PinePhone (pine64-pinephone) / PineTab (pine64-pinetab)
          # Power button
          "0:0:axp20x-pek" = {
            inherit repeat_delay repeat_rate xkb_file;
          };
          # Volume buttons
          "1:1:1c21800.lradc" = {
            inherit repeat_delay repeat_rate xkb_file;
          };

          ### PinePhone Pro (pine64-pinephonepro)
          # Power button
          "1:1:gpio-key-power" = {
            inherit repeat_delay repeat_rate xkb_file;
          };
        };
      keybindings = lib.mkOptionDefault {
        "Mod1+d" = "exec ${pkgs.bemenu}/bin/bemenu-run --list 10 --prompt 'Run:'";
      };
      output.DSI-1.scale = "1.5";
    };

    extraConfig = ''
      exec ${pkgs.wvkbd}/bin/wvkbd-mobintl

      exec ${pkgs.sxmo-utils}/bin/sxmo_multikey.sh clear

      ### PinePhone (pine64-pinephone) / PineTab (pine64-pinetab)
      # Multikey handling for power button
      bindsym --input-device=0:0:axp20x-pek XF86PowerOff \
          exec ${pkgs.sxmo-utils}/bin/sxmo_multikey.sh powerbutton \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh powerbutton_one" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh powerbutton_two" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh powerbutton_three"
      # Multikey handling for volup button
      bindsym --input-device=1:1:1c21800.lradc XF86AudioRaiseVolume \
          exec ${pkgs.sxmo-utils}/bin/sxmo_multikey.sh volup \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh volup_one" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh volup_two" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh volup_three"
      # Multikey handling for voldown button
      bindsym --input-device=1:1:1c21800.lradc XF86AudioLowerVolume \
          exec ${pkgs.sxmo-utils}/bin/sxmo_multikey.sh voldown \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh voldown_one" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh voldown_two" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh voldown_three"

      ### PinePhone Pro (pine64-pinephonepro)
      # Multikey handling for power button
      bindsym --input-device=1:1:gpio-key-power XF86PowerOff \
          exec ${pkgs.sxmo-utils}/bin/sxmo_multikey.sh powerbutton \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh powerbutton_one" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh powerbutton_two" \
          "${pkgs.sxmo-utils}/bin/sxmo_inputhandler.sh powerbutton_three"
    '';
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-mobile;
    profiles.default = { };
  };

  programs.foot = {
    enable = true;
    settings.main.dpi-aware = "no";
  };

  home.packages = with pkgs;[
    sxmo-utils

    # sxmo-utils deps
    busybox
    jq
  ];

  home.sessionVariables = {
    SXMO_WM = "sway";
  };

  home.stateVersion = "21.11";
}
