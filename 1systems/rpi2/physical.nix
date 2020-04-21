{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/rpi3b+.nix>
  ];

  swapDevices = [
    {
      device = "/swapfile";
    }
  ];
}
