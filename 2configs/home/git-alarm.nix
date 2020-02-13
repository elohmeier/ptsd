{ config, lib, pkgs, ... }:

let
  unstable = import <nixpkgs-unstable> {}; # for mu-repo
in
{
  systemd.user.services.git-alarm = {
    Unit = {
      Description = "Run git-alarm and generate i3status file";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.git-alarm}/bin/git-alarm -o ${config.xdg.dataHome}/git-alarm.txt ${config.home.homeDirectory}/repos";
      TimeoutStartSec = "2min"; # kill if still alive after 2 minutes
      Environment = "PATH=${pkgs.git}/bin:${unstable.mu-repo}/bin";
    };
  };

  systemd.user.timers.git-alarm = {
    Unit = {
      Description = "git-alarm Timer";
    };

    Timer = {
      OnCalendar = "*:0/5";
      Unit = "git-alarm.service";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };

  programs.git.extraConfig.core.hooksPath = "${pkgs.git-alarm}/share/hooks";
}
