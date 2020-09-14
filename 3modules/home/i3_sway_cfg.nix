{ config, lib, pkgs, modifier ? "Mod4", cfg }:

with lib;
let
  exit_mode = "exit: [l]ogout, [r]eboot, reboot-[w]indows, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";
  open_codium_mode = "codium: [n]obbofin, nix[p]kgs";
in
{
  options = {
    enable = mkEnableOption "i3/sway window manager";
    showBatteryStatus = mkOption {
      type = types.bool;
      default = false;
    };
    showWifiStatus = mkOption {
      type = types.bool;
      default = false;
    };
    showNvidiaGpuStatus = mkOption {
      type = types.bool;
      default = false;
    };
    extraDiskBlocks = mkOption {
      type = with types; listOf attrs;
      default = [ ];
    };
    ethIf = mkOption {
      type = types.str;
      default = "eth0";
      description = "for i3status";
    };
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
      default = 8;
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
    openweathermapApiKey = mkOption {
      type = types.str;
      default = "";
    };
    todoistApiKey = mkOption {
      type = types.str;
      default = "";
    };
  };

  inherit modifier;
  keybindings =
    {
      "${modifier}+Return" = "exec i3-sensible-terminal";
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

      "${modifier}+Shift+Delete" = "exec ${pkgs.nwlock}/bin/nwlock";
      #"${modifier}+Shift+Return" = "exec i3-sensible-terminal -cd \"`${pkgs.xcwd}/bin/xcwd`\"";  # urxvt
      "${modifier}+Shift+Return" = "exec i3-sensible-terminal --working-directory \"`${pkgs.xcwd}/bin/xcwd`\""; # alacritty
      "${modifier}+Shift+c" = "exec codium \"`${pkgs.xcwd}/bin/xcwd`\"";
      "${modifier}+Shift+t" = "exec ${pkgs.pcmanfm}/bin/pcmanfm \"`${pkgs.xcwd}/bin/xcwd`\"";

      "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
      "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

      "XF86AudioMute" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.primarySpeaker} toggle";
      "XF86AudioLowerVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} -5%";
      "XF86AudioRaiseVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} +5%";
      "XF86AudioMicMute" = mkIf (cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

      #"XF86Calculator" = "exec i3-sensible-terminal -title bc -e ${pkgs.bc}/bin/bc -l";  # urxvt
      "XF86Calculator" = "exec i3-sensible-terminal --title bc -e ${pkgs.bc}/bin/bc -l"; # alacritty
      "XF86HomePage" = "exec chromium";
      "XF86Search" = "exec chromium";
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

      # urxvt
      #"${modifier}+numbersign" = "split horizontal;; exec i3-sensible-terminal -cd \"`${pkgs.xcwd}/bin/xcwd`\"";
      #"${modifier}+minus" = "split vertical;; exec i3-sensible-terminal -cd \"`${pkgs.xcwd}/bin/xcwd`\"";

      # alacritty
      "${modifier}+numbersign" = "split horizontal;; exec i3-sensible-terminal --working-directory \"`${pkgs.xcwd}/bin/xcwd`\"";
      "${modifier}+minus" = "split vertical;; exec i3-sensible-terminal --working-directory \"`${pkgs.xcwd}/bin/xcwd`\"";

      "${modifier}+a" = ''[class="Firefox"] scratchpad show'';
      "${modifier}+b" = ''[class="Firefox"] scratchpad show'';

      # Take a screenshot
      "${modifier}+Ctrl+Shift+4" = "exec flameshot gui";
    };

  modes = {
    "${open_codium_mode}" = {
      "n" = ''exec codium /home/enno/repos/nobbofin; mode "default"'';
      "p" = ''exec codium /home/enno/repos/nixpkgs; mode "default"'';
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
      # font size must be appended to the *last* item in this list
      fonts = [ cfg.fontMono "FontAwesome5Free" "FontAwesome5Brands ${toString cfg.fontSize}" ];
      statusCommand = "${config.ptsd.i3status-rust.package}/bin/i3status-rs ${config.xdg.configHome}/i3/status.toml";
    }
  ];

  extraConfig = ''
    set $ws1 "1"
    set $ws2 "2"
    set $ws3 "3"
    set $ws4 "4"
    set $ws5 "5"
    set $ws6 "6"
    set $ws7 "7"
    set $ws8 "8"
    set $ws9 "9"
    set $ws10 "10"
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
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = "solarized_alternate";
  };

  packages = with pkgs; [
    # TODO: disabled for 20.09 until fix has landed in 20.09 (https://github.com/NixOS/nixpkgs/pull/97965)
    #libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
    playerctl
    pcmanfm
    ethtool
  ];

  home_session_variables = {
    QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
  };

  i3status-rust_config = {
    theme = {
      name = "solarized-dark";
      overrides = {
        idle_bg = "#181516";
        idle_fg = "#ffffff";
      };
    };
    icons = "awesome5";
    block = [
      # {
      #   block = "pomodoro";
      #   length = 25;
      #   break_length = 5;
      #   message = "Take a break!";
      #   break_message = "Back to work!";
      #   use_nag = true;
      # }
      {
        block = "custom";
        command = "cat ${config.xdg.dataHome}/git-alarm.txt";
        interval = 5;

        # cannot be triggered
        # TODO: switch to custom_dbus (https://github.com/greshake/i3status-rust/pull/687)
        #command = "${pkgs.git-alarm}/bin/git-alarm $HOME/repos";
        #interval = 100;
      }
      {
        block = "music";
        player = "spotify";
        buttons = [ "play" "next" ];
      }
      {
        block = "temperature";
        collapsed = false;
        interval = 10;
        good = 0;
        idle = 55;
        info = 65;
        warning = 80;
      }
    ] ++ optional
      cfg.showNvidiaGpuStatus
      {
        block = "nvidia_gpu";
        interval = 10;
      }
    ++ [
      # device won't be found always
      # {
      #   # Logitech Mouse
      #   block = "battery";
      #   driver = "upower";
      #   device = "hidpp_battery_0";
      #   format = "L {percentage}%";
      #   good = 60;
      #   info = 40;
      #   warning = 20;
      #   critical = 10;
      # }
      {
        block = "disk_space";
        path = "/";
        alias = "/";
        warning = 0.5;
        alert = 0.1;
      }
      {
        block = "disk_space";
        path = "/home";
        alias = "/home";
        warning = 5;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/persist";
        alias = "/persist";
        warning = 0.5;
        alert = 0.2;
      }
    ] ++ cfg.extraDiskBlocks ++ [
      {
        block = "disk_space";
        path = "/var/src";
        alias = "/var/src";
        warning = 0.3;
        alert = 0.1;
      }
      {
        block = "disk_space";
        path = "/nix";
        alias = "/nix";
        warning = 5;
        alert = 1;
      }
      {
        block = "disk_space";
        path = "/tmp";
        alias = "/tmp";
        warning = 5;
        alert = 1;
      }
    ] ++ optional cfg.showWifiStatus {
      block = "net";
      device = "wlp59s0";
      ip = true;
      speed_up = true;
      speed_down = true;
      interval = 5;
    }
    ++ [
      {
        block = "net";
        device = "nwvpn";
        format = "{ip}";
        interval = 100;
      }
      {
        block = "net";
        device = cfg.ethIf;
        format = "{ip} {speed_up} {graph_up} {speed_down} {graph_down}";
        interval = 5;
      }
      # {
      #   block = "cpu";
      #   interval = 5;
      # }
    ] ++ optional cfg.showBatteryStatus {
      block = "battery";
      #driver = "upower"
      interval = 10;
      format = "{percentage}% {time}";
    }
    ++ [
      {
        block = "load";
        interval = 5;
        format = "{1m}";
      }
      {
        block = "memory";
        display_type = "memory";
        format_mem = "{Mup}%";
        format_swap = "{SUp}%";
        interval = 5;
      }
      #{
      #  block = "sound";
      #}
      {
        block = "custom";
        command = "${pkgs.todoist-i3status}/bin/todoist-i3status -token ${cfg.todoistApiKey}";
        on_click = "xdg-open https://todoist.com/app/";
        json = true;
        interval = 60;
      }
      {

        block = "time";
        interval = 60;
        format = "%a %F %R";
      }
      {
        block = "weather";
        interval = 300;
        format = "{weather} ({location}) {temp}°, {wind} m/s {direction}";
        service = {
          name = "openweathermap";
          api_key = cfg.openweathermapApiKey;
          #city_id = "2928381"; # Pelzerhaken
          city_id = "2911298"; # Hamburg
          units = "metric";
        };
      }
    ];
  };
}
