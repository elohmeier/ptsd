{ pkgs, ... }:
let
  weatherbg = pkgs.writeShellScriptBin "weatherbg" ''
    ${pkgs.wget}/bin/wget -O /tmp/bwk_bodendruck_na_ana.png https://www.dwd.de/DWD/wetter/wv_spez/hobbymet/wetterkarten/bwk_bodendruck_na_ana.png
    ${pkgs.wget}/bin/wget -O /tmp/bwk_bodendruck_weu_ana.png https://www.dwd.de/DWD/wetter/wv_spez/hobbymet/wetterkarten/bwk_bodendruck_weu_ana.png

    ${pkgs.feh}/bin/feh --image-bg "#8390A1" --bg-max /tmp/bwk_bodendruck_na_ana.png /tmp/bwk_bodendruck_weu_ana.png
  '';
in
{
  systemd.user.services.weatherbg = {
    Unit = {
      Description = "Fetch wallpaper from DWD";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${weatherbg}/bin/weatherbg";
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
}
