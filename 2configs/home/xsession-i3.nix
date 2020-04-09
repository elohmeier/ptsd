{ config, lib, pkgs, ... }:
let
  writeSong = pkgs.writers.writeDash "write-current-song" ''
    ${pkgs.playerctl}/bin/playerctl metadata --format '{{xesam:artist}} - {{xesam:title}}' > ${config.xdg.dataHome}/current_song.txt
    rc=$?; if [[ $rc != 0 ]]; then echo "" > ${config.xdg.dataHome}/current_song.txt; fi
  '';
in
{
  xsession.enable = true;

  imports = [
    <ptsd/2configs/home/file-manager.nix>
    <ptsd/2configs/home/git-alarm.nix>
  ];

  ptsd.i3 = {
    enable = true;
  };

  home.packages = with pkgs;
    [
      sxiv # image viewer
      lxmenu-data # pcmanfm: show "installed applications"
      shared_mime_info # pcmanfm: recognise different file types
    ];


  systemd.user.services.current-song = {
    Unit = {
      Description = "Run playerctl and generate i3status file";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${writeSong}";
      TimeoutStartSec = "2min"; # kill if still alive after 2 minutes
    };
  };

  systemd.user.timers.current-song = {
    Unit = {
      Description = "current-song Timer";
    };

    Timer = {
      Unit = "current-song.service";
      OnUnitInactiveSec = "5s";
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };

}
