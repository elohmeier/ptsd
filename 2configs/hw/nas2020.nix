{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
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

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "uas"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "hid_microsoft"
  ];

  boot.initrd.kernelModules = [ "dm-snapshot" ];

  boot.kernelModules = [ "kvm-intel" ];

  #boot.kernelParams = [
  #"mitigations=off" # make linux fast again
  #];

  nix.maxJobs = lib.mkDefault 4;

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="a8:a1:59:04:c6:f8", NAME="eth0"
  '';

  hardware.cpu.intel.updateMicrocode = true;

  i18n.consoleKeyMap = "de-latin1";

  # High-DPI console
  i18n.consoleFont = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
}
