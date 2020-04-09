{ config, lib, pkgs, ... }:
let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
in
{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # don't remove, wifi will be lost :-)
  ];

  systemd.services.wol-eth0 = {
    description = "Wake-on-LAN for eth0";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s eth0 wol g"; # magicpacket
    };
  };

  # turn on numlock in X11 by default
  services.xserver.displayManager.lightdm.extraSeatDefaults =
    "greeter-setup-script=${pkgs.numlockx}/bin/numlockx on";

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = super:
      let
        self = super.pkgs;
      in
        {
          linuxPackages = unstable.linuxPackages_latest.extend (
            self: super: {
              nvidiaPackages = super.nvidiaPackages
              // {
                stable = unstable.linuxPackages_latest.nvidiaPackages.stable;
              }
              ;
            }
          );
        };
  };

  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  services.fwupd.enable = true;

  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "hid_microsoft"
    "r8169" # Ethernet
  ];

  boot.kernelModules = [ "kvm-amd" "wl" ];

  boot.kernelParams = [
    "mitigations=off" # make linux fast again
    "nordrand" # https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1690085
    "acpi_osi=Linux" # (try) fix shutdown bug
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta config.boot.kernelPackages.nvidia_x11 ];
  boot.kernelPackages = pkgs.linuxPackages; # pkgs.linuxPackages is overridden, see nixpkgs.config in this file
  boot.zfs.enableUnstable = true;
  boot.supportedFilesystems = [ "zfs" ];
  services.zfs = {
    autoScrub = { enable = true; };
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
  };

  nix.maxJobs = lib.mkDefault 24;
  #powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # sample to pass USB access to VM
  # see https://github.com/NixOS/nixpkgs/issues/27199
  # SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="90cc", GROUP="users", MODE="0777"

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.amd.updateMicrocode = true;

  hardware.opengl = {
    driSupport32Bit = true; # for Steam
    extraPackages = with pkgs; [];
    extraPackages32 = with pkgs.pkgsi686Linux; [];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  console.keyMap = "de-latin1";

  # set DPI
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      Xft.dpi: 150
    EOF
  '';
}
