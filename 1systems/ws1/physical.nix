{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/ws2019.nix>
  ];

  fileSystems."/" = {
    device = "nw99/enc/nixos";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/863C-8DEE";
    fsType = "vfat";
  };

  swapDevices = [];
}
