{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.i3;
  i3font = "${cfg.font} ${toString cfg.fontSize}";
in
{
  imports = [
    ./i3status.nix
    ./i3status-rust.nix
  ];

  options.ptsd.i3 = {
    enable = mkEnableOption "i3 window manager";
    showBatteryStatus = mkOption {
      type = types.bool;
      default = true;
    };
    showWifiStatus = mkOption {
      type = types.bool;
      default = false;
    };
    ethIf = mkOption {
      type = types.str;
      default = "eth0";
      description = "for i3status";
    };
    font = mkOption {
      type = types.str;
      default = "DejaVu Sans"; # TODO: expose package, e.g. for gtk
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
  };

  config = mkIf cfg.enable {
    xsession = {
      windowManager.i3 =
        let
          modifier = config.xsession.windowManager.i3.config.modifier;
          exit_mode = "exit: [l]ogout, [r]eboot, reboot-[w]indows, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";
          open_codium_mode = "codium: [n]obbofin, nix[p]kgs";
        in
          {
            enable = true;
            config = {
              modifier = "Mod4";
              keybindings =
                {
                  "${modifier}+Return" = "exec i3-sensible-terminal";
                  "${modifier}+Shift+q" = "kill";
                  "${modifier}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

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
                  "XF86Launch9" = "exec spotify"; # Label: 5

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

              modes."${open_codium_mode}" = {
                "n" = ''exec codium /home/enno/repos/nobbofin; mode "default"'';
                "p" = ''exec codium /home/enno/repos/nixpkgs; mode "default"'';
                "Escape" = ''mode "default"'';
                "Return" = ''mode "default"'';
              };

              modes."${exit_mode}" = {
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

              startup = [
                { command = "i3-msg workspace 1"; notification = false; }
              ];

              # to get the class of a window run `xprop WM_CLASS` and click on the window
              window.commands = [
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

              modes.resize = {

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

              fonts = [ i3font ];

              bars = [
                {
                  colors.background = "#181516";
                  # font size must be appended to the *last* item in this list
                  fonts = [ "Source Code Pro for Powerline" "FontAwesome5Free" "FontAwesome5Brands ${toString cfg.fontSize}" ];

                  statusCommand = "${config.ptsd.i3status-rust.package}/bin/i3status-rs ${config.xdg.configHome}/i3/status.toml";
                }
              ];
            };

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
          };

      pointerCursor = {
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ-AA";
      };
    };

    gtk = {
      enable = true;
      font = {
        name = "${cfg.font} ${toString cfg.fontSize}";
        package = pkgs.dejavu_fonts;
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

    home.packages = with pkgs; [
      i3lock # only needed for config testing / man pages
      libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
      playerctl
      brightnessctl
      flameshot
      pcmanfm
      nwlock
    ];

    home.sessionVariables = {
      QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
    };

    ptsd.i3status = {
      enable = false;
      blocks = {
        general.opts = {
          colors = true;
          interval = 5;
          color_good = "#35d689";
        };

        wireless = {
          type = "wireless";
          name = "_first_";
          opts = {
            format_up = "W: (%quality at %essid) %ip";
            format_down = "W: down";
          };
        };

        ethernet = {
          type = "ethernet";
          name = cfg.ethIf;
          opts = {
            format_up = "E: %ip";
            format_down = "E: down";
          };
        };

        ethernet_nwvpn = {
          type = "ethernet";
          name = "nwvpn";
          opts = {
            format_up = "NVPN: %ip";
            format_down = "NVPN: down";
          };
        };

        battery = {
          type = "battery";
          name = "all";
          opts.format = "%status %percentage %remaining";
        };

        cputemp_ws1_temp1 = {
          type = "cpu_temperature";
          name = "ws1_temp1";
          opts = {
            format = "C1: %degrees °C";
            path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon1/temp1_input";
            max_threshold = 60;
          };
        };

        cputemp_ws1_temp2 = {
          type = "cpu_temperature";
          name = "ws1_temp2";
          opts = {
            format = "C2: %degrees °C";
            path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon1/temp2_input";
            max_threshold = 60;
          };
        };

        cputemp_ws1_temp3 = {
          type = "cpu_temperature";
          name = "ws1_temp3";
          opts = {
            format = "C3: %degrees °C";
            path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon1/temp3_input";
            max_threshold = 60;
          };
        };

        cputemp_ws1_temp4 = {
          type = "cpu_temperature";
          name = "ws1_temp4";
          opts = {
            format = "C4: %degrees °C";
            path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon1/temp4_input";
            max_threshold = 60;
          };
        };

        tztime = {
          type = "tztime";
          name = "local";
          opts.format = "%Y-%m-%d %H:%M:%S";
        };

        load = {
          type = "load";
          opts.format = "%1min";
        };

        disk_home = {
          type = "disk";
          name = "/home";
          opts.format = "/home %avail";
        };

        disk_nix = {
          type = "disk";
          name = "/nix";
          opts.format = "/nix %avail";
        };

        disk_var = {
          type = "disk";
          name = "/var";
          opts.format = "/var %avail";
        };

        disk_var_lib_docker = {
          type = "disk";
          name = "/var/lib/docker";
          opts.format = "/var/lib/docker %avail";
        };

        disk_var_lib_libvirt_images = {
          type = "disk";
          name = "/var/lib/libvirt/images";
          opts.format = "/var/lib/libvirt/images %avail";
        };

        disk_var_log = {
          type = "disk";
          name = "/var/log";
          opts.format = "/var/log %avail";
        };

        disk_var_src = {
          type = "disk";
          name = "/var/src";
          opts.format = "/var/src %avail";
        };

        disk_persist = {
          type = "disk";
          name = "/persist";
          opts.format = "/persist %avail";
        };

        disk_root = {
          type = "disk";
          name = "/";
          opts.format = "/ %avail";
        };

        memory = {
          type = "memory";
          #opts.format = "%percentage_used used, %percentage_free free, %percentage_shared shared";
          opts = {
            format = "%used";
            threshold_degraded = "10%";
            format_degraded = "MEMORY: %free";
          };
        };

        read_file_gitalarm = {
          type = "read_file";
          name = "gitalarm";
          opts = {
            path = "${config.xdg.dataHome}/git-alarm.txt";
          };
        };

        read_file_current_song = {
          type = "read_file";
          name = "current_song";
          opts = {
            path = "${config.xdg.dataHome}/current_song.txt";
          };
        };

        volume_master = {
          type = "volume";
          name = "master";
          opts = {
            format = "♪: %volume";
            format_muted = "♪: muted (%volume)";
            device = "pulse";
          };
        };
      };

      order = [
        "read_file gitalarm"
        "read_file current_song"
        "ipv6"
        "cpu_temperature ws1_temp1"
        "cpu_temperature ws1_temp2"
        "cpu_temperature ws1_temp3"
        "cpu_temperature ws1_temp4"
        "disk /"
        "disk /home"
        "disk /persist"
        "disk /var"
        "disk /var/lib/docker"
        "disk /var/lib/libvirt/images"
        "disk /var/log"
        "disk /var/src"
        "disk /nix"
      ] ++ optional cfg.showWifiStatus "wireless _first_"
      ++ [ "ethernet ${cfg.ethIf}" "ethernet nwvpn" ]
      ++ optional cfg.showBatteryStatus "battery all"
      ++ [
        "load"
        "memory"
        "volume master"
        "tztime local"
      ];
    };

    ptsd.i3status-rust = {
      enable = true;
      config = {
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
            interval = 100;
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
          {
            block = "nvidia_gpu";
            interval = 10;
          }
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
          {
            block = "disk_space";
            path = "/var";
            alias = "/var";
            warning = 2;
            alert = 1;
          }
          {
            block = "disk_space";
            path = "/var/lib/docker";
            alias = "/var/lib/docker";
            warning = 2;
            alert = 1;
          }
          {
            block = "disk_space";
            path = "/var/lib/libvirt/images";
            alias = "/var/lib/libvirt/images";
            warning = 2;
            alert = 1;
          }
          {
            block = "disk_space";
            path = "/var/log";
            alias = "/var/log";
            warning = 1;
            alert = 0.5;
          }
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
            block = "net";
            device = "nwvpn";
            ip = true;
            speed_up = false;
            speed_down = false;
            interval = 100;
          }
          # {
          #   block = "cpu";
          #   interval = 5;
          # }
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
          {
            block = "sound";
          }
          {

            block = "time";
            interval = 60;
            format = "%a %F %R";
          }
        ];
      };
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
          font = "Source Code Pro ${toString cfg.fontSize}";
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
