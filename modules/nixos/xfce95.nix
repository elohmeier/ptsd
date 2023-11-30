{ config, lib, pkgs, ... }: {
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
    displayManager.lightdm = {
      background = "#008080";
      greeters.gtk = {
        cursorTheme = {
          package = pkgs.chicago95;
          name = "Chicago95 Animated Hourglass Cursors";
        };
        iconTheme = {
          package = pkgs.chicago95;
          name = "Chicago95";
        };
        theme = {
          package = pkgs.chicago95;
          name = "Chicago95";
        };
        extraConfig = ''
          font-name=Helvetica 8
        '';
      };
    };
    layout = lib.mkDefault "us";
    libinput.enable = true;
    libinput.touchpad.naturalScrolling = true;
    libinput.mouse.naturalScrolling = true;
    xkbOptions = "eurosign:e,terminate:ctrl_alt_bksp,compose:ralt";
  };
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };
  boot.plymouth = {
    enable = true;
    logo = ../../src/Microsoft_Windows_95_wordmark.png;
  };
  environment.systemPackages = [
    pkgs.chicago95
    pkgs.pavucontrol
    pkgs.libinput
    pkgs.xclip
    pkgs.xfce.xfce4-pulseaudio-plugin
    pkgs.xfce.xfce4-fsguard-plugin
    pkgs.xsel
  ];
  fonts.fonts = [ pkgs.chicago95 ];
}
