{ config, lib, pkgs, ... }:

with lib;
let
  inherit (config.boot.kernelPackages) nvidia_x11;
  inherit (config.nixpkgs.hostPlatform) isx86_64;
in
{
  imports = [
    ./.
    ./fish.nix
    ./users/root.nix
  ];

  boot = {
    blacklistedKernelModules = optional isx86_64 "nouveau";

    extraModulePackages = optional isx86_64 nvidia_x11.bin;

    initrd = {
      availableKernelModules = [
        "9p"
        "9pnet_virtio"
        "ahci"
        "ata_piix"
        "ehci_pci"
        "hid_microsoft"
        "ntfs3"
        "nvme"
        "ohci_pci"
        "sd_mod"
        "sr_mod"
        "uhci_hcd"
        "usb_storage"
        "usbhid"
        "virtio_blk"
        "virtio_mmio"
        "virtio_net"
        "virtio_pci"
        "virtio_scsi"
        "xhci_pci"
      ];

      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ] ++ optional (isx86_64) "amdgpu";

      systemd = {
        enable = mkDefault true;
        emergencyAccess = true;
      };
    };

    kernelPackages = mkDefault pkgs.linuxPackages_latest;

    kernelModules = optionals isx86_64 [
      "kvm-amd"
      "kvm-intel"
      "nvidia-uvm"
    ];

    tmpOnTmpfs = true;
  };

  powerManagement.cpuFreqGovernor = mkDefault "schedutil";

  hardware.cpu.amd.updateMicrocode = isx86_64;
  hardware.cpu.intel.updateMicrocode = isx86_64;
  hardware.enableAllFirmware = true;

  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree
    broadcom-bt-firmware # for the plugable USB stick
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = isx86_64;
    extraPackages = with pkgs; optionals isx86_64 [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs; optional isx86_64 driversi686Linux.amdvlk;
  };

  console.font = "${pkgs.spleen}/share/consolefonts/spleen-8x16.psfu";

  services.xserver = {
    videoDrivers = optional isx86_64 "amdgpu";
  };

  environment.systemPackages = with pkgs; optionals isx86_64 [
    # cudatoolkit # large
    cifs-utils
    cryptsetup
    git
    hashPassword
    home-manager
    nvidia_x11.bin
    nvidia_x11.persistenced
    nvidia_x11.settings
    nvtop
  ];

  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  services.resolved = {
    enable = true;
    # dnssec = "false";
  };

  # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = mkIf config.services.syncthing.enable 204800;

  ptsd.secrets.enable = false;
  ptsd.tailscale.enable = true;

  services.udisks2.enable = lib.mkDefault false;
  security.sudo.wheelNeedsPassword = false;
  nix.settings.trusted-users = [ "root" "@wheel" ];
}
