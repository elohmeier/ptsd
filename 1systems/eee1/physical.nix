{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/eee901.nix>
  ];

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  fileSystems."/var/src" = {
    device = "/dev/sdb2";
    fsType = "ext4";
  };

  swapDevices = [{ device = "/dev/sdb1"; }];

  services.haveged.enable = true;
}
