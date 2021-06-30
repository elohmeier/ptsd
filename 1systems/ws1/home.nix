{ config, lib, pkgs, ... }:
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/gpg.nix
  ];

  home.stateVersion = "20.09";
  programs.fish = {
    enable = true;
    shellAliases = (import ../../2configs/aliases.nix).aliases;
    shellAbbrs = (import ../../2configs/aliases.nix).abbreviations;
  };

  wayland.windowManager.sway = {
    extraConfig = ''
      output DP-3 pos 0 0 mode 3840x2160@59.997002Hz scale 1.859375
      output DP-4 pos 2064 0 mode 3840x2160@59.997002Hz scale 1.859375
    '';

    # extraConfig = ''
    #   output DP-4 pos 0 1052 mode 3840x2160@59.997002Hz scale 1.859375
    #   output DP-8 pos 0 0 mode 4096x2304@59.999001Hz scale 2.191406
    #   output DP-2 pos 2064 1052 mode 3840x2160@59.997002Hz scale 1.859375
    # '';

    # both on nvidia:
    # extraConfig = ''
    #   output DP-3 pos 0 0 mode 3840x2160@59.997002Hz scale 2
    #   output DP-4 pos 1920 0 mode 3840x2160@59.999001Hz scale 2
    # '';
  };

  home = {
    packages = with pkgs; [
      lguf-brightness
    ];
  };

  ptsd.pcmanfm.enableRdpAssistant = true;

  xsession.initExtra = ''
    # disable screensaver
    ${pkgs.xorg.xset}/bin/xset s off -dpms
  '';
}
