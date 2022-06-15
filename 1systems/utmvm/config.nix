{ config, lib, pkgs, ... }: {

  imports = [
    ../../2configs
    ../../2configs/users/enno.nix
    ../../2configs/fish.nix
  ];

  boot.kernel.sysctl = {
    # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
    "fs.inotify.max_user_watches" = 204800;
  };

  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = with pkgs;[
    git
    home-manager
  ];

  services.udisks2.enable = false;

  ptsd.secrets.enable = false;

  # spice-vdagent does not support resizing the screen, only X11
  # services.getty.autologinUser = "enno";
  # programs.sway.enable = true;
  # environment.variables = {
  #   WLR_RENDERER = "pixman";
  #   WLR_NO_HARDWARE_CURSORS = "1";
  # };

  services.spice-vdagentd.enable = true;

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "enno";
      };
      xserverArgs = [ "-ardelay 200" "-arinterval 45" ];
    };

    layout = "de";
    windowManager.i3.enable = true;

    libinput = {
      enable = true;
      mouse.naturalScrolling = true;
    };
  };

  system.stateVersion = "22.05";
}
