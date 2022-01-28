{ config, lib, pkgs, ... }:

{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  boot = {
    blacklistedKernelModules = [ "b43" "bcma" ]; # prevent loading of conflicting wifi module, "wl" should be used instead
    extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
    ];
    initrd = {
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "hid_microsoft"
        "r8169" # Ethernet
      ];

      kernelModules = [
        "amdgpu"
      ];
    };

    kernelModules = [ "kvm-amd" "wl" ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "broadcom-sta"
  ];
}
