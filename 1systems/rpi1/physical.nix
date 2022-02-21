{ config, lib, pkgs, ... }:

{
  imports = [
    ./config.nix
    ../../2configs/hw/rpi3b-readonly.nix
  ];
}
