{ config, lib, pkgs, ... }:
let
  desktopSecrets = import <secrets-shared/desktop.nix>;
in
{
  xsession.enable = true;

  imports = [
    <ptsd/3modules/home>
    #<ptsd/2configs/home/git-alarm.nix> # TODO: Port to nwi3status
  ];

  services.screen-locker = {
    enable = true;
    lockCmd = lib.mkDefault "${pkgs.i3lock}/bin/i3lock";
    # lockCmd = "${pkgs.nwlock}/bin/nwlock";
    # xssLockExtraOptions = [
    #   "-n"
    #   "${pkgs.nwlock}/libexec/xsecurelock/dimmer" # nwlock package wraps custom xsecurelock
    #   "-l" # make sure not to allow machine suspend before the screen saver is active
    # ];
  };

  systemd.user.services.flameshot = {
    Unit = {
      Description = "Screenshot Tool";
    };

    Service = {
      ExecStart = "${pkgs.flameshot}/bin/flameshot";
      RestartSec = 3;
      Restart = "on-failure";
    };
  };

  ptsd.i3 = {
    enable = true;
    screenshotCommand = "exec ${pkgs.flameshot}/bin/flameshot gui";
  };

  ptsd.nwi3status = {
    enable = true;
    openweathermapApiKey = desktopSecrets.openweathermapApiKey;
  };

  ptsd.pcmanfm.enable = true;

  home.packages = with pkgs;[
    xorg.xev
    xorg.xhost
    flameshot
  ];
}
