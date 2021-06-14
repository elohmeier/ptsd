{ config, lib, pkgs, ... }:
{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  boot = {
    blacklistedKernelModules = [ "b43" "bcma" ]; # prevent loading of conflicting wifi module, "wl" should be used instead
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
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

      kernelModules = [ "amdgpu" ];
    };

    kernelModules = [ "kvm-amd" "wl" ];
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v24n.psf.gz";
  console.keyMap = "de-latin1";

  environment.systemPackages = with pkgs; [ clinfo vulkan-tools ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];
    # nvidia.nvidiaPersistenced = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ amdvlk rocm-opencl-icd rocm-runtime ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ driversi686Linux.amdvlk ];
    };
  };

  # required to enable nvidia NixOS module, even if not using X11
  # services.xserver.videoDrivers = [ "nvidia" ];

  nix.maxJobs = lib.mkDefault 24;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
