{ config, lib, pkgs, ... }:

{
  services.xserver.desktopManager = {
    default = "xfce";
    xfce = {
      enable = true;
    };
  };
}
