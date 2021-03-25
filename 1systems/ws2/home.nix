{ config, lib, pkgs, ... }:
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/firefox.nix
    ../../2configs/home/gpg.nix
  ];

  wayland.windowManager.sway = {
    extraConfig = ''
      output DP-1 pos 0 0 mode 2560x1440@74.924004Hz scale 1
      output HDMI-A-2 pos 2560 0 mode 2560x1440@69.928001Hz scale 1
    '';
  };
}
