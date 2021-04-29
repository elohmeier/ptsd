{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ../../2configs/hw/rpi3b+.nix
  ];

  swapDevices = [
    {
      device = "/swapfile";
    }
  ];
}
