{ config, lib, pkgs, ... }:

{
  services.xserver.desktopManager = {
    defaultSession = "xfce";
    xfce = {
      enable = true;
    };
  };
}
