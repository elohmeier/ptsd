{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../minimal.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  boot.initrd = {
    availableKernelModules =
      [ "ata_piix" "uhci_hcd" "virtio_net" "virtio_pci" "sd_mod" "sr_mod" ];
  };

  nix.settings.max-jobs = lib.mkDefault 1;
}
