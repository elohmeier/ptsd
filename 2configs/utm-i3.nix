{ config, lib, pkgs, ... }:

{
  # spice-vdagent does not support resizing the screen, only X11
  # services.getty.autologinUser = "enno";
  # programs.sway.enable = true;
  # environment.variables = {
  #   WLR_RENDERER = "pixman";
  #   WLR_NO_HARDWARE_CURSORS = "1";
  # };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "enno";
      };
      xserverArgs = [
        # keyboard repeat rate settings
        "-ardelay 200"
        "-arinterval 45"

        # prevent alacritty crashing on too large windows
        # see https://github.com/alacritty/alacritty/issues/3500
        "-maxbigreqsize 127"
      ];
    };
    layout = "de";
    windowManager.i3.enable = true;
    libinput = {
      enable = true;
      mouse.naturalScrolling = true;
    };
  };
}
