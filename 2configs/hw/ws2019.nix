{ config, lib, pkgs, ... }:

let
  nvidia_x11 = config.boot.kernelPackages.nvidia_x11;
in
{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  boot = {
    blacklistedKernelModules = [ "b43" "bcma" ]; # prevent loading of conflicting wifi module, "wl" should be used instead
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta nvidia_x11.bin ];
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

      kernelModules = [ "amdgpu" "nvidia-uvm" ];
    };

    kernelModules = [ "kvm-amd" "wl" ];
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v24n.psf.gz";
  console.keyMap = "de-latin1";

  environment.systemPackages = with pkgs; [
    clinfo
    vulkan-tools
    nvidia_x11.bin
    nvidia_x11.settings
    nvidia_x11.persistenced
    nvtop
  ];

  hardware = {
    cpu.amd.updateMicrocode = true;
    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [ amdvlk rocm-opencl-icd rocm-runtime nvidia_x11.out ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ driversi686Linux.amdvlk nvidia_x11.lib32 ];
    };
  };

  systemd.services.nvidia-persistenced =
    {
      description = "NVIDIA Persistence Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        Restart = "always";
        PIDFile = "/var/run/nvidia-persistenced/nvidia-persistenced.pid";
        ExecStart = "${nvidia_x11.persistenced}/bin/nvidia-persistenced --verbose";
        ExecStopPost = "${pkgs.coreutils}/bin/rm -rf /var/run/nvidia-persistenced";
      };
    };

  services.udev.extraRules =
    ''
      # Create /dev/nvidia-uvm when the nvidia-uvm module is loaded.
      KERNEL=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidiactl c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 255'"
      KERNEL=="nvidia_modeset", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-modeset c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) 254'"
      KERNEL=="card*", SUBSYSTEM=="drm", DRIVERS=="nvidia", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia%n c $$(grep nvidia-frontend /proc/devices | cut -d \  -f 1) %n'"
      KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
      KERNEL=="nvidia_uvm", RUN+="${pkgs.runtimeShell} -c 'mknod -m 666 /dev/nvidia-uvm-tools c $$(grep nvidia-uvm /proc/devices | cut -d \  -f 1) 0'"
    '';

  nix.maxJobs = lib.mkDefault 24;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
