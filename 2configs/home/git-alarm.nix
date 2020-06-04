{ config, lib, pkgs, ... }:

{
  systemd.user.services.git-alarm = {
    Unit = {
      Description = "Run git-alarm and generate i3status file";
    };

    Service = {
      Type = "oneshot";
      # TODO: switch to custom_dbus (https://github.com/greshake/i3status-rust/pull/687)
      ExecStart = "${pkgs.git-alarm}/bin/git-alarm -o ${config.xdg.dataHome}/git-alarm.txt ${config.home.homeDirectory}/repos";
      TimeoutStartSec = "30sec"; # kill if still alive after 30 seconds
      Environment = "PATH=${pkgs.git}/bin:${pkgs.mu-repo}/bin";
    };
  };

  systemd.user.timers.git-alarm = {
    Unit = {
      Description = "git-alarm Timer";
    };

    Timer = {
      OnCalendar = "*:0/5"; # every 5 minutes
      Unit = "git-alarm.service";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };

  programs.git.extraConfig.core.hooksPath = "${pkgs.git-alarm}/share/hooks";
}
