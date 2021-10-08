{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  hardware = {
    bluetooth = {
      enable = cfg.bluetooth.enable;
      hsphfpd.enable = true;
      package = pkgs.bluezFull;
    };
  };

  services.blueman.enable = cfg.bluetooth.enable;

}
