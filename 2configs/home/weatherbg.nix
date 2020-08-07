{ pkgs, ... }:
{
  systemd.user.services.weatherbg = {
    Unit = {
      Description = "Fetch wallpaper from DWD";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.weatherbg}/bin/weatherbg";
      TimeoutStartSec = "30sec"; # kill if still alive after 30 seconds
    };
  };

  systemd.user.timers.weatherbg = {
    Unit = {
      Description = "weatherbg Timer";
    };

    Timer = {
      OnCalendar = "*-*-* *:05:00"; # every hour
      OnStartupSec = 3; # after first user login
      Unit = "weatherbg.service";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };

  home.packages = [ pkgs.weatherbg ];
}
