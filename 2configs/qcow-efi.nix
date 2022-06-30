{ config, lib, pkgs, modulesPath, ... }:

{
  boot = {
    growPartition = true;
    initrd.availableKernelModules = [ "uas" ];
    kernelParams = [ "console=ttyS0" ];
    loader.grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    loader.timeout = 0;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
  };

  system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    partitionTableType = "efi";
    diskSize = "auto";
    format = "qcow2";
  };
}
