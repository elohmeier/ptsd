{ config, lib, pkgs, ... }:

{
  imports = [
    ./config.nix
  ];

  fileSystems."/" = {
    #device = "/dev/disk/by-partuuid/a8977403-ac7e-4daf-abaa-ece7e998d9fd";
    #fsType = "ext4";

    device = "/dev/disk/by-partuuid/048be6e9-fd03-4768-b41c-f470a78c06e6";
    fsType = "f2fs";
  };

  fileSystems."/boot" = {
    #device = "/dev/disk/by-partuuid/444c6553-d5cd-4676-826b-73516e0a13b5";
    #fsType = "vfat";

    device = "/dev/disk/by-partuuid/c2e61eb7-0132-4bcb-b195-fa8f4f833b2a";
    fsType = "ext4";
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
}
