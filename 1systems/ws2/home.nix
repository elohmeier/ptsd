{ config, lib, pkgs, ... }:

let
  # nix has no float2int conversion
  roundDown = f: lib.toInt (builtins.elemAt (lib.splitString "." (toString f)) 0);
in
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/gpg.nix
  ];
  home.stateVersion = "20.09";
  wayland.windowManager.sway = {
    #  extraConfig = ''
    #    output DP-1 pos 0 0 mode 2560x1440@74.924004Hz scale 1
    #    output HDMI-A-2 pos 2560 0 mode 2560x1440@69.928001Hz scale 1
    #  '';
    extraConfig = let scale = 1.25; in
      ''
        output HDMI-A-1 pos 0 0 mode 2560x1440@69.928001Hz scale ${toString scale}
        output HDMI-A-2 pos ${toString (roundDown (2560 / scale))} 0 mode 2560x1440@69.928001Hz scale ${toString scale}
      '';
  };
}
