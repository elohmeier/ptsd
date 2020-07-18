{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/apu2.nix>
  ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/297096e3-cf98-4401-87cf-2831f6995139";
      fsType = "ext4";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/a5a9cdaf-107d-4ee2-b7eb-6bc65edd7a89"; }];
}
