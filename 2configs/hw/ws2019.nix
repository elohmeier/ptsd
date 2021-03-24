{ config, lib, pkgs, ... }:
{
  # Only 5Ghz Wifi with a low channel (like 40) is supported
  # See https://wiki.archlinux.org/index.php/Broadcom_wireless#No_5GHz_for_BCM4360_(14e4:43a0)_/_BCM43602_(14e4:43ba)_devices

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix> # don't remove, wifi will be lost :-)
  ];

  systemd.services.wol-eth0 = {
    description = "Wake-on-LAN for enp39s0";
    requires = [ "network.target" ];
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ethtool}/bin/ethtool -s enp39s0 wol g"; # magicpacket
    };
  };

  boot.kernel.sysctl."kernel.sysrq" = 1; # allow all SysRq key combinations

  #services.fwupd.enable = true;

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

  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelModules = [ "kvm-amd" "wl" ];

  boot.kernelParams = [
    "mitigations=off" # make linux fast again
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  nix.maxJobs = lib.mkDefault 24;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # sample to pass USB access to VM
  # see https://github.com/NixOS/nixpkgs/issues/27199
  # SUBSYSTEM=="usb", ATTR{idVendor}=="072f", ATTR{idProduct}=="90cc", GROUP="users", MODE="0777"

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.cpu.amd.updateMicrocode = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ amdvlk ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ driversi686Linux.amdvlk ];
  };

  console.keyMap = "de-latin1";

  services.xserver = {
    # set DPI
    dpi = 150;
    displayManager = {
      sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
          Xft.dpi: 150
        EOF
      '';

      # turn on numlock in X11 by default
      lightdm.extraSeatDefaults =
        "greeter-setup-script=${pkgs.numlockx}/bin/numlockx on";
    };
  };
}
