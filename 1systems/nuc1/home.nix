{ config, lib, pkgs, ... }:
let
  baresipSecrets = import <secrets/baresip.nix>;
  homeSecrets = import <client-secrets/home-secrets.nix>;
in
{
  imports = [
    ../../2configs/home
    ../../2configs/home/extraTools.nix
    ../../2configs/home/gpg.nix
  ];

  # dual iiyama
  wayland.windowManager.sway.extraConfig = ''
    output HDMI-A-1 pos 0 0 mode 2560x1440@59.951000Hz scale 1.333333333
    output HDMI-A-2 pos 1920 0 mode 1920x1080@60.000000Hz scale 1
  '';

  # full hd + iiyama
  # wayland.windowManager.sway.extraConfig = ''
  #   output HDMI-A-1 pos 0 0 mode 1920x1080@59.933998Hz scale 1
  #   output HDMI-A-2 pos 1920 120 mode 1920x1200@59.950001Hz scale 1
  # '';

  ptsd.baresip = {
    enable = true;
    username = "nuc1baresip";
    registrar = "192.168.178.1";
    password = baresipSecrets.password;
    netInterface = "nwvpn";
  };
}
