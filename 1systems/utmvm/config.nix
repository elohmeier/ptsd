{ config, lib, pkgs, ... }: {

  imports = [
    ../../2configs
  ];

  environment.systemPackages = with pkgs;[
    git
  ];

  services.getty.autologinUser = "enno";

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
    };

    layout = "de";

    # LG UltraFine Display
    monitorSection = ''
      Modeline "4096x2304_60.00" 812.47 4096 4432 4888 5680  2304 2305 2308 2384  -HSync +Vsync
      Option "PreferredMode" "4096x2304_60.00"
    '';

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

  system.stateVersion = "22.05";

}
