{ config, lib, pkgs, ... }:

{
  imports = [
    ../../2configs/home
  ];
  home.stateVersion = "20.09";
  wayland.windowManager.sway = {
    extraConfig = let scale = 1.25; in
      ''
        output "Iiyama North America PL2791Q 1153904821492" pos 0 0 mode 2560x1440@60Hz scale 1
        output "Iiyama North America PL2791Q 1153903322321" pos 2560 0 mode 2560x1440@60Hz scale 1
      '';
  };
  programs.foot.settings.main = {
    font = "Cozette";
    dpi-aware = "no";
  };
}
