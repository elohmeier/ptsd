{ ... }: {

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # save space
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];
  hardware.wirelessRegulatoryDatabase = true;
  services.udisks2.enable = false;
}
