{ config, lib, pkgs, ... }:

{
  services.xserver.displayManager.defaultSession = "xfce";
  services.xserver.desktopManager.xfce = {
    enable = true;
  };
}
