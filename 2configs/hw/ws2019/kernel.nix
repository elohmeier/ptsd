{ config, lib, ... }:

{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  boot = {
    blacklistedKernelModules = [ "b43" "bcma" ]; # prevent loading of conflicting wifi module, "wl" should be used instead
    extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
      # (config.boot.kernelPackages.broadcom_sta.overrideAttrs (old: {
      #   patches = old.patches ++ [
      #     (pkgs.fetchpatch {
      #       url = "https://gist.githubusercontent.com/joanbm/052d8e951ba63d5eb5b6960bfe4e031a/raw/a9c9fc7238cdda5ff0175009644321f3b855979e/broadcom-wl-fix-linux-5.18.patch";
      #       sha256 = "sha256-/idB8e4F7Kl+IO+M3g1jHdmv6PhNgQ3ZOqMpUk1l48Y=";
      #     })
      #   ];
      # }))
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
