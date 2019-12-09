{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.i3;
  i3font = "${cfg.defaultFont} ${toString cfg.defaultFontSize}";
in
{
  imports = [
    ./i3status.nix
  ];

  options.ptsd.i3 = {
    enable = mkEnableOption "i3 window manager";
    primaryScreenWidth = mkOption {
      type = types.int;
      description = "Used for i3lock image generation.";
    };
    primaryScreenHeight = mkOption {
      type = types.int;
      description = "Used for i3lock image generation.";
    };
    useBattery = mkOption {
      type = types.bool;
      description = "Used for i3status config.";
      default = true;
    };
    useWifi = mkOption {
      type = types.bool;
      description = "Used for i3status config.";
      default = true;
    };
    ethIf = mkOption {
      type = types.str;
      default = "eth0";
      description = "Ethernet interface for i3status config.";
    };
    consoleTheme = mkOption {
      type = types.str;
      default = "solarized_dark";
    };
    defaultFont = mkOption {
      type = types.str;
      default = "DejaVu Sans";
    };
    monospaceFont = mkOption {
      type = types.str;
      default = "Consolas";
    };
    defaultFontSize = mkOption {
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
              mkOptionDefault {
                "${modifier}+Shift+Delete" = "exec ${pkgs.i3lock}/bin/i3lock --color=000000 --show-failed-attempts"; # TODO: add lockpaper
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

                "${modifier}+0" = "workspace 10";
                "${modifier}+Shift+0" = "move container to workspace 10";

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
                command = "floating enable, move to scratchpad, scratchpad show";
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
        };

    gtk = {
      enable = true;
      font = {
        name = "${cfg.defaultFont} ${toString cfg.defaultFontSize}";
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
    ];

    programs.urxvt = let
      font = cfg.monospaceFont;
      fontSize = toString cfg.defaultFontSize;
      themes = {
        solarized_dark = {
          "background" = "#002b36";
          "foreground" = "#839496";
          "fadeColor" = "#002b36";
          "cursorColor" = "#93a1a1";
          "pointerColorBackground" = "#586e75";
          "pointerColorForeground" = "#93a1a1";
          "color0" = "#073642";
          "color8" = "#002b36";
          "color1" = "#dc322f";
          "color9" = "#cb4b16";
          "color2" = "#859900";
          "color10" = "#586e75";
          "color3" = "#b58900";
          "color11" = "#657b83";
          "color4" = "#268bd2";
          "color12" = "#839496";
          "color5" = "#d33682";
          "color13" = "#6c71c4";
          "color6" = "#2aa198";
          "color14" = "#93a1a1";
          "color7" = "#eee8d5";
          "color15" = "#fdf6e3";
        };
        solarized_light = {
          "background" = "#fdf6e3";
          "foreground" = "#657b83";
          "fadeColor" = "#fdf6e3";
          "cursorColor" = "#586e75";
          "pointerColorBackground" = "#93a1a1";
          "pointerColorForeground" = "#586e75";
          "color0" = "#073642";
          "color8" = "#002b36";
          "color1" = "#dc322f";
          "color9" = "#cb4b16";
          "color2" = "#859900";
          "color10" = "#586e75";
          "color3" = "#b58900";
          "color11" = "#657b83";
          "color4" = "#268bd2";
          "color12" = "#839496";
          "color5" = "#d33682";
          "color13" = "#6c71c4";
          "color6" = "#2aa198";
          "color14" = "#93a1a1";
          "color7" = "#eee8d5";
          "color15" = "#fdf6e3";
        };
      };
    in
      {
        enable = true;
        package = pkgs.rxvt_unicode-with-plugins;
        extraConfig = {
          saveLines = 100000;
          scrollBar = false;
          urgentOnBell = true;
          perl-ext-common = "default,clipboard,url-select,keyboard-select";
          "url-select.underline" = true;
          "url-select.launcher" = "firefox";

          intensityStyles = false;
        } // themes."${cfg.consoleTheme}";
        fonts = [
          "xft:${font}:size=${fontSize}"
          "xft:${font}:size=${fontSize}:bold"
        ];
        keybindings = {
          "M-u" = "perl:url-select:select_next";
          "M-Escape" = "perl:keyboard-select:activate";
          "M-s" = "perl:keyboard-select:search";

          "M-F1" = "command:\\033]710;xft:${font}:size=6\\007\\033]711;xft:${font}:size=6:bold\\007";
          "M-F2" = "command:\\033]710;xft:${font}:size=${fontSize}\\007\\033]711;xft:${font}:size=${fontSize}:bold\\007";
          "M-F3" = "command:\\033]710;xft:${font}:size=11\\007\\033]711;xft:${font}:size=11:bold\\007";
          "M-F4" = "command:\\033]710;xft:${font}:size=25\\007\\033]711;xft:${font}:size=25:bold\\007";
          "M-F5" = "command:\\033]710;xft:${font}:size=30\\007\\033]711;xft:${font}:size=30:bold\\007";
        };
      };

    home.sessionVariables = {
      TERM = "xterm-256color";
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

        disk_root = {
          type = "disk";
          name = "/";
          opts.format = "%avail";
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
      ] ++ optional cfg.useWifi [ "wireless _first_" ]
      ++ [ "ethernet ${cfg.ethIf}" ]
      ++ optional cfg.useBattery [ "battery all" ]
      ++ [
        "load"
        "memory"
        "volume master"
        "tztime local"
      ];
    };

    xdg.dataFile."file-manager/actions/nobbofin_assign_fzf.desktop".text = lib.generators.toINI {} {
      "Desktop Entry" = {
        Type = "Action";
        Name = "Assign PDF to Nobbofin Transaction";
        Profiles = "assign;";
      };

      "X-Action-Profile assign" = {
        MimeTypes = "application/pdf";
        Exec = "urxvt -e /home/enno/nobbofin/assign-doc-fzf.py %f";
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
        };
        urgency_low.timeout = 1;
      };
    };
  };
}
