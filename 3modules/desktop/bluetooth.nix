{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  hardware = {
    bluetooth = {
      inherit (cfg.bluetooth) enable;
      # hsphfpd.enable = cfg.bluetooth.enable && !config.ptsd.bootstrap;
      package = pkgs.bluezFull;
    };
  };

  services.blueman.enable = lib.mkDefault cfg.bluetooth.enable;
}
