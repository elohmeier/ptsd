{ config, lib, pkgs, ... }:

{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  boot = {
    blacklistedKernelModules = [ "b43" "bcma" ]; # prevent loading of conflicting wifi module, "wl" should be used instead
    extraModulePackages = [
      (config.boot.kernelPackages.broadcom_sta.overrideAttrs (old: {
        patches = old.patches ++ [
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/NixOS/nixpkgs/077d187a4b37ba81ebe9f6985c1dbd0b19f6d33d/pkgs/os-specific/linux/broadcom-sta/linux-5.17.patch";
            sha256 = "sha256-Ba6xtCJK3Jfwbj93zYqOuOjUAMKoZ48Z97vnLnfKWJo=";
          })
        ]; # TODO: waits for BP https://github.com/NixOS/nixpkgs/pull/166232 to stable or 22.05
      }))
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
