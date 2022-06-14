{ config, lib, pkgs, ... }: {

  programs.i3status = {
    enable = true;
    enableDefault = false;
    general = {
      colors = true;
      interval = 5;
    };
    modules = {
      ipv6.position = 1;

      "wireless _first_" = {
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

      "ethernet nwvpn" = {
        position = 3;
        settings = {
          format_up = "旅 nw: %ip";
          format_down = " nw: down";
        };
      };

      "ethernet tun0" = {
        position = 3;
        settings = {
          format_up = "旅 t0: %ip";
          format_down = " t0: down";
        };
      };

      "battery all" = {
        position = 4;
        settings = { format = "%status %percentage %remaining"; };
      };

      "disk /" = {
        position = 5;
        settings.format = " / %avail";
      };

      "disk /home" = {
        position = 5;
        settings.format = " h %avail";
      };

      "disk /nix" = {
        position = 5;
        settings.format = " n %avail";
      };

      "disk /run/user/1000" = {
        position = 5;
        settings.format = " xrd %avail";
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
        settings = { format = "%Y-%m-%d %H:%M:%S"; };
      };

    };
  };

}
