{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.i3;
  i3font = "${cfg.font} ${toString cfg.fontSize}";
in
{
  imports = [
    ./i3status.nix
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
    xsession.windowManager.i3 =
      let
        modifier = config.xsession.windowManager.i3.config.modifier;
        exit_mode = "exit: [l]ogout, [r]eboot, [s]hutdown, s[u]spend-then-hibernate, [h]ibernate, sus[p]end";
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
                "${modifier}+Shift+Return" = "exec i3-sensible-terminal -cd \"`${pkgs.xcwd}/bin/xcwd`\"";
                "${modifier}+Shift+c" = "exec codium \"`${pkgs.xcwd}/bin/xcwd`\"";
                "${modifier}+Shift+t" = "exec ${pkgs.pcmanfm}/bin/pcmanfm \"`${pkgs.xcwd}/bin/xcwd`\"";

                "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
                "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

                "XF86AudioMute" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.primarySpeaker} toggle";
                "XF86AudioLowerVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} -5%";
                "XF86AudioRaiseVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} +5%";
                "XF86AudioMicMute" = mkIf (cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

                "XF86Calculator" = "exec i3-sensible-terminal -title bc -e ${pkgs.bc}/bin/bc -l";

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

                "${modifier}+numbersign" = "split horizontal;; exec i3-sensible-terminal -cd \"`${pkgs.xcwd}/bin/xcwd`\"";
                "${modifier}+minus" = "split vertical;; exec i3-sensible-terminal -cd \"`${pkgs.xcwd}/bin/xcwd`\"";

                "${modifier}+a" = ''[class="Firefox"] scratchpad show'';
                "${modifier}+b" = ''[class="Firefox"] scratchpad show'';

                # Take a screenshot
                "${modifier}+Ctrl+Shift+4" = "exec flameshot gui";
              };

            modes."${open_codium_mode}" = {
              "n" = ''exec codium /home/enno/nobbofin; mode "default"'';
              "p" = ''exec codium /home/enno/nixpkgs; mode "default"'';
              "Escape" = ''mode "default"'';
              "Return" = ''mode "default"'';
            };

            modes."${exit_mode}" = {
              "l" = ''exec i3-msg exit; mode "default"'';
              "r" = ''exec systemctl reboot; mode "default"'';
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
                fonts = [ i3font ];
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

    xsession.pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ-AA";
    };

    home.packages = with pkgs; [
      i3status
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
      enable = true;
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

        battery = {
          type = "battery";
          name = "all";
          opts.format = "%status %percentage %remaining";
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

        disk_root = {
          type = "disk";
          name = "/";
          opts.format = "/ %avail";
        };

        memory = {
          type = "memory";
          opts.format = "%percentage_used used, %percentage_free free, %percentage_shared shared";
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
        "ipv6"
        "disk /"
        "disk /home"
        "disk /var"
        "disk /nix"
      ] ++ optional cfg.showWifiStatus "wireless _first_"
      ++ [ "ethernet ${cfg.ethIf}" ]
      ++ optional cfg.showBatteryStatus "battery all"
      ++ [
        "load"
        "memory"
        "volume master"
        "tztime local"
      ];
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
        };
        urgency_low.timeout = 1;
      };
    };
  };
}
