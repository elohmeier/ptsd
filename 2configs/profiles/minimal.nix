{ config, lib, pkgs, ... }:

{
  # reduce size
  environment.noXlibs = lib.mkDefault true;
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ ];
  hardware.wirelessRegulatoryDatabase = true;
  services.udisks2.enable = false;
  security.polkit.enable = false;
}
