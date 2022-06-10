{ config, lib, pkgs, ... }: {

  imports = [
    ../../2configs
  ];

  environment.systemPackages = with pkgs;[
    git
  ];

  programs.sway.enable = true;

  services.getty.autologinUser = "enno";

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        i3blocks #if you are planning on using i3blocks over i3status
      ];
    };
  };


  #services.xserver = {
  #  enable = true;
  #  displayManager.sddm.enable = true;
  #};

}
