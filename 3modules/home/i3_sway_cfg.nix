{ config, lib, pkgs, modifier ? "Mod4", cfg }:

with lib;
let
  exit_mode = "exit: [l]ogout, [r]eboot, reboot-[w]indows, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";
  open_codium_mode = "codium: [p]tsd, nobbo[f]in, [n]ixpkgs";

  terminalConfigs = {
    alacritty = prog: dir: "alacritty${if dir != "" then " --working-directory \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}";
    kitty = prog: dir: "kitty${if dir != "" then " --directory \"${dir}\"" else ""}${if prog != "" then " ${prog}" else ""}";
    urxvt = prog: dir: "urxvt${if dir != "" then " -cd \"${dir}\"" else ""}${if prog != "" then " -e ${prog}" else ""}";
    xterm = prog: dir: "xterm${if prog != "" then " -e ${prog}" else ""}"; # xterm does not support working directory switching
  };

  term = terminalConfigs.${cfg.terminalConfig};
in
{
  options = {
    enable = mkEnableOption "i3/sway window manager";
    fontSans = mkOption {
      type = types.str;
      default = "Iosevka Sans"; # TODO: expose package, e.g. for gtk
    };
    fontMono = mkOption {
      type = types.str;
      default = "Iosevka";
    };
    fontSize = mkOption {
      type = types.int;
      default = 10;
    };
    primaryMicrophone = mkOption {
      type = with types; nullOr str;
      description = "Pulseaudio microphone device name";
      default = "@DEFAULT_SOURCE@";
    };
    primarySpeaker = mkOption {
      type = with types; nullOr str;
      description = "Pulseaudio speaker device name";
      default = "@DEFAULT_SINK@";
    };
    configureGtk = mkOption {
      type = types.bool;
      default = true;
    };
    configureRofi = mkOption {
      type = types.bool;
      default = true;
    };
    terminalConfig = mkOption {
      type = types.str;
      default = "xterm";
    };
    lockCmd = mkOption {
      type = types.str;
      default = "${pkgs.i3lock}/bin/i3lock";
    };
    trayOutput = mkOption {
      type = types.str;
      default = "primary";
      description = "Where to output tray.";
    };
  };

  inherit modifier;
  keybindings =
    {
      "${modifier}+Return" = "exec ${term "" ""}";
      "${modifier}+Shift+q" = "kill";
      #"${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
      "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show combi";

      "${modifier}+Left" = "focus left";
      "${modifier}+Down" = "focus down";
      "${modifier}+Up" = "focus up";
      "${modifier}+Right" = "focus right";

      "${modifier}+Shift+Left" = "move left";
      "${modifier}+Shift+Down" = "move down";
      "${modifier}+Shift+Up" = "move up";
      "${modifier}+Shift+Right" = "move right";

      "${modifier}+f" = "fullscreen toggle";

      "${modifier}+s" = "layout stacking";
      "${modifier}+w" = "layout tabbed";
      "${modifier}+e" = "layout toggle split";

      "${modifier}+Shift+space" = "floating toggle";
      "${modifier}+space" = "focus mode_toggle";

      # "Space-Hack" to fix the ordering in the generated config file
      # This prevents that i3 uses this order: 10, 1, 2, ...
      " ${modifier}+1" = "workspace $ws1";
      " ${modifier}+2" = "workspace $ws2";
      " ${modifier}+3" = "workspace $ws3";
      " ${modifier}+4" = "workspace $ws4";
      " ${modifier}+5" = "workspace $ws5";
      " ${modifier}+6" = "workspace $ws6";
      " ${modifier}+7" = "workspace $ws7";
      " ${modifier}+8" = "workspace $ws8";
      " ${modifier}+9" = "workspace $ws9";
      "${modifier}+0" = "workspace $ws10";

      "${modifier}+Shift+1" = "move container to workspace $ws1";
      "${modifier}+Shift+2" = "move container to workspace $ws2";
      "${modifier}+Shift+3" = "move container to workspace $ws3";
      "${modifier}+Shift+4" = "move container to workspace $ws4";
      "${modifier}+Shift+5" = "move container to workspace $ws5";
      "${modifier}+Shift+6" = "move container to workspace $ws6";
      "${modifier}+Shift+7" = "move container to workspace $ws7";
      "${modifier}+Shift+8" = "move container to workspace $ws8";
      "${modifier}+Shift+9" = "move container to workspace $ws9";
      "${modifier}+Shift+0" = "move container to workspace $ws10";

      "${modifier}+Shift+r" = "restart";

      "${modifier}+r" = "mode resize";

      "${modifier}+Shift+Delete" = "exec ${cfg.lockCmd}";
      "${modifier}+Shift+Return" = "exec ${term "" "`${pkgs.xcwd}/bin/xcwd`"}";
      "${modifier}+Shift+c" = "exec codium \"`${pkgs.xcwd}/bin/xcwd`\"";
      "${modifier}+Shift+t" = "exec pcmanfm \"`${pkgs.xcwd}/bin/xcwd`\"";

      "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%+";
      "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%-";

      "XF86AudioMute" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.primarySpeaker} toggle";
      "XF86AudioLowerVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} -5%";
      "XF86AudioRaiseVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} +5%";
      "XF86AudioMicMute" = mkIf (cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

      "XF86Calculator" = "exec ${term "${pkgs.bc}/bin/bc -l" ""}";
      "XF86HomePage" = "exec firefox";
      "XF86Search" = "exec firefox";
      "XF86Mail" = "exec evolution";
      "XF86Launch5" = "exec spotify"; # Label: 1
      "XF86Launch8" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo -5%"; # Label: 4
      "XF86Launch9" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume alsa_output.usb-LG_Electronics_Inc._USB_Audio-00.analog-stereo +5%"; # Label: 5

      "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "${modifier}+p" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
      "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
      "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
      "${modifier}+n" = "exec ${pkgs.playerctl}/bin/playerctl next";
      "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
      "${modifier}+Shift+n" = "exec ${pkgs.playerctl}/bin/playerctl previous";

      "${modifier}+h" = "focus left";
      "${modifier}+Shift+u" = "resize shrink width 20 px or 20 ppt";

      "${modifier}+j" = "focus down";
      "${modifier}+Shift+i" = "resize shrink height 20 px or 20 ppt";

      "${modifier}+k" = "focus up";
      "${modifier}+Shift+o" = "resize grow height 20 px or 20 ppt";

      "${modifier}+l" = "focus right";
      "${modifier}+Shift+p" = "resize grow width 20 px or 20 ppt";

      "${modifier}+Home" = "workspace 1";
      "${modifier}+Prior" = "workspace prev";
      "${modifier}+Next" = "workspace next";
      "${modifier}+End" = "workspace 10";
      "${modifier}+Tab" = "workspace back_and_forth";

      # not working
      #"${modifier}+p" = ''[instance="scratch-term"] scratchpad show'';

      "${modifier}+c" = ''mode "${open_codium_mode}"'';

      "${modifier}+Shift+e" = ''mode "${exit_mode}"'';

      "${modifier}+numbersign" = "split horizontal;; exec ${term "" "`${pkgs.xcwd}/bin/xcwd`"}";
      "${modifier}+minus" = "split vertical;; exec ${term "" "`${pkgs.xcwd}/bin/xcwd`"}";

      "${modifier}+a" = ''[class="Firefox"] scratchpad show'';
      "${modifier}+b" = ''[class="Firefox"] scratchpad show'';

      # Take a screenshot
      "${modifier}+Ctrl+Shift+4" = "exec flameshot gui";
    };

  modes = {
    "${open_codium_mode}" = {
      "n" = ''exec codium /home/enno/repos/nixpkgs; mode "default"'';
      "p" = ''exec codium /home/enno/repos/ptsd; mode "default"'';
      "f" = ''exec codium /home/enno/repos/nobbofin; mode "default"'';
      "Escape" = ''mode "default"'';
      "Return" = ''mode "default"'';
    };

    "${exit_mode}" = {
      "l" = ''exec i3-msg exit; mode "default"'';
      "r" = ''exec systemctl reboot; mode "default"'';
      "w" = ''exec systemctl reboot --boot-loader-entry=auto-windows; mode "default"'';
      "s" = ''exec systemctl poweroff; mode "default"'';
      "u" = ''exec systemctl suspend-then-hibernate; mode "default"'';
      "p" = ''exec systemctl suspend; mode "default"'';
      "h" = ''exec systemctl hibernate; mode "default"'';
      "Escape" = ''mode "default"'';
      "Return" = ''mode "default"'';
    };

    resize = {
      "Left" = "resize shrink width 10 px or 10 ppt";
      "Down" = "resize grow height 10 px or 10 ppt";
      "Up" = "resize shrink height 10 px or 10 ppt";
      "Right" = "resize grow width 10 px or 10 ppt";
      "Escape" = "mode default";
      "Return" = "mode default";
      "${modifier}+r" = "mode default";
      "j" = "resize shrink width 10 px or 10 ppt";
      "k" = "resize grow height 10 px or 10 ppt";
      "l" = "resize shrink height 10 px or 10 ppt";
      "odiaeresis" = "resize grow width 10 px or 10 ppt";
    };
  };

  startup = [
    { command = "i3-msg workspace 1"; notification = false; }
  ];

  # to get the class of a window run `xprop WM_CLASS` and click on the window
  window_commands = [
    # not working
    #{
    #  command = ''floating enable, move to scratchpad'';
    #  criteria.instance = "scratch-term";
    #}
    {
      criteria.class = "Firefox";
      command = "floating enable, resize set 90 ppt 90 ppt, move position center, move to scratchpad, scratchpad show";
    }
    {
      criteria.class = ".blueman-manager-wrapped";
      command = "floating enable";
    }
    {
      criteria.class = "Pavucontrol";
      command = "floating enable";
    }
  ];

  fonts = [ "${cfg.fontSans} ${toString cfg.fontSize}" ];

  bars = [
    {
      colors.background = "#181516";
      # font size must be appended to the *last* item in this list, see https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-from-string
      fonts = [ cfg.fontMono "Material Design Icons" "Typicons" "Font Awesome 5 Free" "Font Awesome 5 Brands ${toString cfg.fontSize}" ];
      statusCommand = "exec ${pkgs.nwi3status}/bin/nwi3status";
      trayOutput = cfg.trayOutput;
    }
  ];

  extraConfig = ''
    set $ws1 1
    set $ws2 2
    set $ws3 3
    set $ws4 4
    set $ws5 5
    set $ws6 6
    set $ws7 7
    set $ws8 8
    set $ws9 9
    set $ws10 10
  '';

  gtk = {
    enable = true;
    font = {
      name = "${cfg.fontSans} ${toString cfg.fontSize}";
      package = pkgs.iosevka;
    };
    iconTheme = {
      name = "Tango";
      package = pkgs.tango-icon-theme;
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  rofi = {
    enable = true;
    font = "${cfg.fontSans} ${toString cfg.fontSize}";
    theme = "solarized_alternate";
  };

  packages = with pkgs; [
    # TODO: disabled for 20.09 until fix has landed in 20.09 (https://github.com/NixOS/nixpkgs/pull/97965)
    #libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
    playerctl
    ethtool
  ];

  home_session_variables = {
    QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
  };
}
