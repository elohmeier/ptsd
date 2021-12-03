{ config, lib, pkgs, ... }:

{
  imports = [
    ../../2configs/home
  ];
  home.stateVersion = "20.09";
  wayland.windowManager.sway.config.output =
    let
      defaults = { mode = "2560x1440@60Hz"; scale = "1"; };
    in
    {
      "Iiyama North America PL2791Q 1153904821492" = defaults // { pos = "0 0"; };
      "Iiyama North America PL2791Q 1153903322321" = defaults // { pos = "2560 0"; };
    };
}
