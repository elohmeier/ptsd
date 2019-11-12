{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.i3;
  i3statusrc = pkgs.writeText "i3statusconfig" ''
    general {
      colors = true
      interval = 5
      color_good = "#35d689"
    }

    order += "ipv6"
    order += "disk /"
    ${optionalString cfg.useWifi ''order += "wireless _first_"''}
    order += "ethernet ${cfg.ethIf}"
    ${optionalString cfg.useBattery ''order += "battery all"''}
    order += "load"
    order += "memory"
    ${optionalString (cfg.primarySpeaker != null) ''order += "volume master"''}
    order += "tztime local"

    wireless _first_ {
      format_up = "W: (%quality at %essid) %ip"
      format_down = "W: down"
    }

    ethernet ${cfg.ethIf} {
      #format_up = "E: %ip (%speed)"
      format_up = "E: %ip"
      format_down = "E: down"
    }

    battery all {
      format = "%status %percentage %remaining"
    }

    tztime local {
      format = "%Y-%m-%d %H:%M:%S"
    }

    load {
      format = "%1min"
    }

    disk "/" {
      format = "%avail"
    }

    memory {
      format = "%percentage_used used, %percentage_free free, %percentage_shared shared"
    }

    ${optionalString (cfg.primarySpeaker != null) ''
    volume master {
      format = "♪: %volume"
      format_muted = "♪: muted (%volume)"
      device = "pulse"
    }
  ''}
  '';
  # alacritty themes
  solarized_light = {

    # Default colors
    primary = {
      background = "0xfdf6e3"; # base3
      foreground = "0x657b83"; # base00
    };

    # Cursor colors
    cursor = {
      text = "0xfdf6e3"; # base3
      cursor = "0x657b83"; # base00
    };

    # Normal colors
    normal = {
      black = "0x073642"; # base02
      red = "0xdc322f"; # red
      green = "0x859900"; # green
      yellow = "0xb58900"; # yellow
      blue = "0x268bd2"; # blue
      magenta = "0xd33682"; # magenta
      cyan = "0x2aa198"; # cyan
      white = "0xeee8d5"; # base2
    };

    # Bright colors
    bright = {
      black = "0x002b36"; # base03
      red = "0xcb4b16"; # orange
      green = "0x586e75"; # base01
      yellow = "0x657b83"; # base00
      blue = "0x839496"; # base0
      magenta = "0x6c71c4"; # violet
      cyan = "0x93a1a1"; # base1
      white = "0xfdf6e3"; # base3
    };
  };
  solarized_dark = {
    # Default colors
    primary = {
      background = "0x002b36"; # base03
      foreground = "0x839496"; # base0
    };

    # Cursor colors
    cursor = {
      text = "0x002b36"; # base03
      cursor = "0x839496"; # base0
    };

    # Normal colors
    normal = {
      black = "0x073642"; # base02
      red = "0xdc322f"; # red
      green = "0x859900"; # green
      yellow = "0xb58900"; # yellow
      blue = "0x268bd2"; # blue
      magenta = "0xd33682"; # magenta
      cyan = "0x2aa198"; # cyan
      white = "0xeee8d5"; # base2
    };

    # Bright colors
    bright = {
      black = "0x002b36"; # base03
      red = "0xcb4b16"; # orange
      green = "0x586e75"; # base01
      yellow = "0x657b83"; # base00
      blue = "0x839496"; # base0
      magenta = "0x6c71c4"; # violet
      cyan = "0x93a1a1"; # base1
      white = "0xfdf6e3"; # base3
    };
  };
in
{
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
    enableAlacritty = mkOption {
      type = types.bool;
      default = true;
      description = "Configure alacritty and setup i3 integration";
    };
    monospaceFont = mkOption {
      type = types.str;
      default = "Consolas 12";
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
      in
        {
          enable = true;
          config = {
            modifier = "Mod4";
            keybindings =
              mkOptionDefault {
                "${modifier}+Shift+Delete" = "exec ${pkgs.i3lock}/bin/i3lock --color=000000 --show-failed-attempts"; # TODO: add lockpaper
                "${modifier}+Shift+Return" = mkIf cfg.enableAlacritty "exec i3-sensible-terminal --working-directory \"`${pkgs.xcwd}/bin/xcwd`\"";
                "${modifier}+Shift+c" = "exec codium \"`${pkgs.xcwd}/bin/xcwd`\"";
                "${modifier}+Shift+t" = "exec ${pkgs.pcmanfm}/bin/pcmanfm \"`${pkgs.xcwd}/bin/xcwd`\"";

                "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
                "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

                "XF86AudioMute" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.primarySpeaker} toggle";
                "XF86AudioLowerVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} -5%";
                "XF86AudioRaiseVolume" = mkIf (cfg.primarySpeaker != null) "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.primarySpeaker} +5%";
                "XF86AudioMicMute" = mkIf (cfg.primaryMicrophone != null) "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute ${cfg.primaryMicrophone} toggle";

                "XF86Calculator" = mkIf cfg.enableAlacritty "exec i3-sensible-terminal --title bc --command ${pkgs.bc}/bin/bc -l";

                "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play";
                "${modifier}+p" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
                "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
                "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
                "${modifier}+n" = "exec ${pkgs.playerctl}/bin/playerctl next";
                "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
                "${modifier}+Shift+n" = "exec ${pkgs.playerctl}/bin/playerctl previous";

                "${modifier}+h" = "focus left";
                "${modifier}+Shift+z" = "resize grow width 2 px or 2 ppt";

                "${modifier}+j" = "focus down";
                "${modifier}+Shift+u" = "resize shrink height 2 px or 2 ppt";

                "${modifier}+k" = "focus up";
                "${modifier}+Shift+i" = "resize grow height 2 px or 2 ppt";

                "${modifier}+l" = "focus right";
                "${modifier}+Shift+o" = "resize shrink width 2 px or 2 ppt";

                "${modifier}+0" = "workspace 10";
                "${modifier}+Shift+0" = "move container to workspace 10";

                "${modifier}+Home" = "workspace 1";
                "${modifier}+Prior" = "workspace prev";
                "${modifier}+Next" = "workspace next";
                "${modifier}+End" = "workspace 10";
                "${modifier}+Tab" = "workspace back_and_forth";

                # not working
                #"${modifier}+p" = ''[instance="scratch-term"] scratchpad show'';

                "${modifier}+c" = ''mode "codium: [n]obbofin, nix[p]kgs"'';

                "${modifier}+Shift+e" = ''mode "exit: [l]ogout, [r]eboot, [s]hutdown"'';
              };

            modes."codium: [n]obbofin, nix[p]kgs" = {
              "n" = ''exec codium /home/enno/nobbofin; mode "default"'';
              "p" = ''exec codium /home/enno/nixpkgs; mode "default"'';
              "Escape" = ''mode "default"'';
              "Return" = ''mode "default"'';
            };

            modes."exit: [l]ogout, [r]eboot, [s]hutdown" = {
              "l" = "exec i3-msg exit";
              "r" = "exec systemctl reboot";
              "s" = "exec systemctl shutdown";
              "Escape" = ''mode "default"'';
              "Return" = ''mode "default"'';
            };

            startup = [
              # not working
              #{ command = "alacritty --class scratch-term"; always = true; }
            ];

            window.commands = [
              # not working
              #{
              #  command = ''floating enable, move to scratchpad'';
              #  criteria.instance = "scratch-term";
              #}
            ];

            # extend the home-manager default config to the upstream i3 default config
            modes.resize = mkOptionDefault {
              "${modifier}+r" = "mode default";
              "j" = "resize shrink width 10 px or 10 ppt";
              "k" = "resize grow height 10 px or 10 ppt";
              "l" = "resize shrink height 10 px or 10 ppt";
              "odiaeresis" = "resize grow width 10 px or 10 ppt";
            };

            fonts = [ cfg.monospaceFont ];

            bars = [
              {
                colors.background = "#181516";
                fonts = [ cfg.monospaceFont ];
              }
            ];
          };
        };

    gtk = {
      enable = true;
      font = {
        name = "DejaVu Sans 10";
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
      i3status
      i3lock # only needed for config testing / man pages
      libsForQt5.qtstyleplugins # required for QT_STYLE_OVERRIDE
      playerctl
      brightnessctl
    ];

    home.sessionVariables = {
      TERMINAL = "alacritty";
      TERM = "xterm-256color";
      QT_STYLE_OVERRIDE = "gtk2"; # for qt5 apps (e.g. keepassxc)
    };

    xdg.configFile."i3status/config".source = i3statusrc;

    programs.alacritty = mkIf cfg.enableAlacritty {
      enable = true;
      settings = {
        font.size = 11.0;
        #colors = solarized_dark;
        colors = solarized_light;
      };
    };
  };
}
