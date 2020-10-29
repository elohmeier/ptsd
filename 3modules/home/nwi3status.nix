{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwi3status;

  configFile =
    pkgs.runCommand "nwi3status-config.toml"
      {
        buildInputs = [ pkgs.remarshal ];
        preferLocalBuild = true;
      } ''
      remarshal -if json -of toml \
        < ${pkgs.writeText "config.json"
        (builtins.toJSON cfg.config)} \
        > $out
    '';
in
{
  options.ptsd.nwi3status = {
    enable = mkEnableOption "nwi3status";
    package = mkOption {
      type = types.package;
      default = pkgs.nwi3status;
    };

    # manual config
    config = mkOption {
      type = types.attrs;
    };

    # config assistant
    showBatteryStatus = mkOption {
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
      default = "";
    };
    wifiIf = mkOption {
      type = types.str;
      default = "";
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

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."i3/nwi3status.toml".source = configFile;

    ptsd.nwi3status.config = {
      TodoistAPIKey = cfg.todoistApiKey;
    };

    #     ptsd.nwi3status.config = {
    #       theme = {
    #         name = "solarized-dark";
    #         overrides = {
    #           idle_bg = "#181516";
    #           idle_fg = "#ffffff";
    #         };
    #       };
    #       icons = "awesome5";
    #       block = [
    #         {
    #           block = "temperature";
    #           collapsed = false;
    #           interval = 10;
    #           good = 0;
    #           idle = 55;
    #           info = 65;
    #           warning = 80;
    #         }
    #         {
    #           block = "music";
    #           player = "spotify";
    #           buttons = [ "play" "next" ];
    #         }
    #       ] ++ optional
    #         cfg.showNvidiaGpuStatus
    #         {
    #           block = "nvidia_gpu";
    #           interval = 10;
    #         }
    #       ++ [
    #         # {
    #         #   block = "pomodoro";
    #         #   length = 25;
    #         #   break_length = 5;
    #         #   message = "Take a break!";
    #         #   break_message = "Back to work!";
    #         #   use_nag = true;
    #         # }
    #         {
    #           block = "weather";
    #           interval = 300;
    #           format = "{weather} ({location}) {temp}°, {wind} m/s {direction}";
    #           service = {
    #             name = "openweathermap";
    #             api_key = cfg.openweathermapApiKey;
    #             #city_id = "2928381"; # Pelzerhaken
    #             city_id = "2911298"; # Hamburg
    #             units = "metric";
    #           };
    #         }
    #       ] ++ [{
    #         block = "custom";
    #         command = "cat ${config.xdg.dataHome}/git-alarm.txt";
    #         interval = 5;
    # 
    #         # cannot be triggered
    #         # TODO: switch to custom_dbus (https://github.com/greshake/nwi3status/pull/687)
    #         #command = "${pkgs.git-alarm}/bin/git-alarm $HOME/repos";
    #         #interval = 100;
    #       }
    #         # device won't be found always
    #         # {
    #         #   # Logitech Mouse
    #         #   block = "battery";
    #         #   driver = "upower";
    #         #   device = "hidpp_battery_0";
    #         #   format = "L {percentage}%";
    #         #   good = 60;
    #         #   info = 40;
    #         #   warning = 20;
    #         #   critical = 10;
    #         # }
    #         {
    #           block = "disk_space";
    #           path = "/";
    #           alias = "/";
    #           warning = 0.5;
    #           alert = 0.1;
    #         }] ++ cfg.extraDiskBlocks
    #       ++ optional (cfg.wifiIf != "") {
    #         block = "net";
    #         device = "wlp59s0";
    #         ip = true;
    #         speed_up = true;
    #         speed_down = true;
    #         interval = 5;
    #       }
    #       ++ [
    #         {
    #           block = "net";
    #           device = "nwvpn";
    #           #format = "{ip}"; # disabled to be compatible with 0.14.1
    #           interval = 100;
    #         }
    #       ]
    #       ++ optional
    #         (cfg.ethIf != "")
    #         {
    #           block = "net";
    #           device = cfg.ethIf;
    #           #format = "{ip} {speed_up} {graph_up} {speed_down} {graph_down}"; # disabled to be compatible with 0.14.1
    #           interval = 5;
    #         } ++ [
    #         # {
    #         #   block = "cpu";
    #         #   interval = 5;
    #         # }
    #         {
    #           block = "custom_dbus";
    #           name = "SyncthingStatus";
    #         }
    #         {
    #           block = "load";
    #           interval = 5;
    #           format = "{1m}";
    #         }
    #         {
    #           block = "memory";
    #           display_type = "memory";
    #           format_mem = "{MFg}%";
    #           format_swap = "{SFg}%";
    #           interval = 5;
    #         }
    #         #{
    #         #  block = "sound";
    #         #}
    # 
    #       ] ++ optional cfg.showBatteryStatus {
    #         block = "battery";
    #         #driver = "upower"
    #         interval = 10;
    #         format = "{percentage}% {time}";
    #       }
    #       ++ [
    #         {
    # 
    #           block = "time";
    #           interval = 60;
    #           format = "%a %F %R";
    #         }
    #       ];
  };
}
