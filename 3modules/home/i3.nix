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
    ${lib.optionalString cfg.useWifi ''order += "wireless _first_"''}
    order += "ethernet ${cfg.ethIf}"
    ${lib.optionalString cfg.useBattery ''order += "battery all"''}
    order += "load"
    order += "memory"
    order += "volume master"
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

    volume master {
      format = "♪: %volume"
      format_muted = "♪: muted (%volume)"
      device = "pulse:1"
    }
  '';
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
  };

  config = mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        modifier = "Mod4";
        keybindings =
          let
            modifier = config.xsession.windowManager.i3.config.modifier;
          in
            mkOptionDefault {
              "${modifier}+Shift+Delete" = "exec ${pkgs.i3lock}/bin/i3lock --color=000000 --show-failed-attempts"; # TODO: add lockpaper
              "${modifier}+Shift+Return" = "exec i3-sensible-terminal --working-directory \"`${pkgs.xcwd}/bin/xcwd`\"";
              "${modifier}+Shift+c" = "exec ${pkgs.vscodium}/bin/codium \"`${pkgs.xcwd}/bin/xcwd`\""; # TODO: remove tight coupling
              "${modifier}+Shift+t" = "exec ${pkgs.pcmanfm}/bin/pcmanfm \"`${pkgs.xcwd}/bin/xcwd`\"";

              "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%+";
              "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 5%-";

              "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute 1 toggle";
              "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 1 -5%";
              "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 1 +5%";
              "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute 2 toggle";

              "XF86Calculator" = "exec i3-sensible-terminal --title bc --command ${pkgs.bc}/bin/bc -l";

            };
        fonts = [ "Consolas 12" ];
        bars = [
          {
            fonts = [ "Consolas 12" ];
          }
        ];
      };
    };

    home.packages = [ pkgs.i3status pkgs.i3lock ]; # only needed for config testing / man pages
    xdg.configFile."i3status/config".source = i3statusrc;
  };
}
