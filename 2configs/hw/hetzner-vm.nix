{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  boot.initrd = {
    availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_net" "virtio_pci" "sd_mod" "sr_mod" ];
  };

  nix.maxJobs = lib.mkDefault 1;
}
