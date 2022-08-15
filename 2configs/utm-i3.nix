{ config, lib, pkgs, ... }:

{
  # spice-vdagent does not support resizing the screen, only X11
  # programs.sway.enable = true;
  # environment.variables = {
  #   WLR_RENDERER = "pixman";
  #   WLR_NO_HARDWARE_CURSORS = "1";
  # };

  services.xserver = {
    enable = lib.mkDefault true;
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
    xkbVariant = "mac";
    windowManager.i3.enable = true;
    libinput = {
      enable = true;
      mouse.naturalScrolling = true;
    };
  };

  specialisation.nogui.configuration = {
    services.xserver.enable = false;
  };

  environment.variables.LIBGL_ALWAYS_SOFTWARE = "1"; # alacritty fix

  services.getty.autologinUser = "enno";

  programs.wireshark.enable = true;
  users.groups.wireshark.members = [ config.users.users.mainUser.name ];
}
