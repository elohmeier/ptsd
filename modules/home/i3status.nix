{ config, lib, ... }:

with lib;
{
  options.programs.i3status = {
    enableWireless = mkEnableOption "wireless";
    enableNwvpn = mkEnableOption "nwvpn";
    enableBattery = mkEnableOption "battery";
  };

  config.programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      colors = true;
      interval = 5;
    };
    modules = with config.programs.i3status; {
      ipv6.position = 1;

      "wireless _first_" = mkIf enableWireless {
        position = 2;
        settings = {
          format_up = "  (%quality at %essid) %ip";
          format_down = "  down";
        };
      };

      "ethernet _first_" = {
        position = 3;
        settings = {
          format_up = "ﯱ e: %ip (%speed)";
          format_down = " e: down";
        };
      };

      "ethernet nwvpn" = mkIf enableNwvpn {
        position = 3;
        settings = {
          format_up = "旅 nw: %ip";
          format_down = " nw: down";
        };
      };

      "ethernet tailscale0" = {
        position = 3;
        settings = {
          format_up = "旅 ts: %ip";
          format_down = " ts: down";
        };
      };

      "ethernet tun0" = {
        position = 3;
        settings = {
          format_up = "旅 tu: %ip";
          format_down = " tu: down";
        };
      };

      "battery all" = mkIf enableBattery {
        position = 4;
        settings = {
          format = "%status %percentage %remaining";
        };
      };

      "disk /" = {
        position = 5;
        settings = {
          format = " / %avail";
          low_threshold = 15;
          threshold_type = "percentage_free";
        };
      };

      "disk /home" = {
        position = 5;
        settings = {
          format = " h %avail";
          low_threshold = 15;
          threshold_type = "percentage_free";
        };
      };

      "disk /nix" = {
        position = 5;
        settings = {
          format = " n %avail";
          low_threshold = 15;
          threshold_type = "percentage_free";
        };
      };

      "disk /run/user/1000" = {
        position = 5;
        settings = {
          format = " xrd %avail";
          low_threshold = 15;
          threshold_type = "percentage_free";
        };
      };

      load = {
        position = 6;
        settings = {
          format = " %1min";
        };
      };

      memory = {
        position = 7;
        settings = {
          format = " %used | %available";
          threshold_degraded = "1G";
          format_degraded = "MEMORY < %available";
        };
      };

      "tztime local" = {
        position = 8;
        settings = {
          format = "%Y-%m-%d %H:%M:%S";
        };
      };

    };
  };

}
