{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/apu1.nix>
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/15bad766-03c3-4362-9d18-4afccde21179";
    fsType = "ext4";
  };
}
