{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # don't remove, wifi will be lost :-)
    <nixos-hardware/lenovo/thinkpad/x280>
  ];

  environment.variables = {
    WINIT_HIDPI_FACTOR = "0.9"; # for alacritty
  };

  services.tlp.enable = true; # TLP Linux Advanced Power Management
  #services.fwupd.enable = true;

  services.xserver = {
    videoDrivers = [ "modesetting" ];
  };

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "hid_microsoft" ];
  boot.kernelModules = [ "kvm-intel" "dm-snapshot" ]; # tp_smapi is not yet compatible
  boot.kernelParams = [
    "zfs.zfs_arc_max=6442451000" # max ARC size: 6GB (instead of default 8GB)
    "mitigations=off" # make linux fast again

    # enable updated GPU firmware loading
    # https://wiki.archlinux.org/index.php/Intel_graphics#Enable_GuC_/_HuC_firmware_loading
    "i915.enable_guc=2"
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # sample to pass USB access to VM
  # see https://github.com/NixOS/nixpkgs/issues/27199
  # SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="90cc", GROUP="users", MODE="0777"

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl = {
    #driSupport32Bit = true; # for Steam
    extraPackages = with pkgs; [
      vaapiIntel
      libvdpau-va-gl
      vaapiVdpau
      intel-ocl
    ];
    #extraPackages32 = with pkgs.pkgsi686Linux; [
    #  vaapiIntel
    #  libvdpau-va-gl
    #  vaapiVdpau
    #];
  };

  services.acpid = {
    enable = true;
    #logEvents = true;
    handlers = {
      ibm-hotkey = {
        action = ''
          bl="/sys/class/leds/tpacpi::kbd_backlight/brightness"

          if [ "$1" = "ibm/hotkey LEN0268:00 00000080 00001315" ]; then
                  current=$(cat $bl)
                  case $current in
                          0)
                                  echo 1 > $bl
                                  ;;
                          1)
                                  echo 2 > $bl
                                  ;;
                          2)
                                  echo 0 > $bl
                                  ;;
                  esac
          fi
        '';
        event = "ibm/hotkey";
      };
    };
  };

  console.keyMap = "de-latin1";
}
