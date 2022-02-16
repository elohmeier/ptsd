{ config, lib, pkgs, ... }:

let
  cfg = config.ptsd.desktop;
in
{
  hardware = {
    bluetooth = {
      enable = cfg.bluetooth.enable && !config.ptsd.bootstrap;
      hsphfpd.enable = cfg.bluetooth.enable && !config.ptsd.bootstrap;
      package = pkgs.bluezFull;
    };
  };

  services.blueman.enable = lib.mkDefault (cfg.bluetooth.enable && !config.ptsd.bootstrap);
}
