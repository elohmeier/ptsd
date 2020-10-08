# let
#   vgPrefix = "/dev/disk/by-id/dm-name-apuvg";
# in
{
  imports = [
    ./config.nix
    <ptsd/2configs/hw/apu1.nix>
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/15bad766-03c3-4362-9d18-4afccde21179";
    fsType = "ext4";
    # fsType = "tmpfs";
    # options = [ "size=500M" "mode=1755" ];
  };

  # fileSystems."/boot" =
  #   {
  #     device = "${vgPrefix}-boot";
  #     fsType = "ext4";
  #   };

  # fileSystems."/nix" =
  #   {
  #     device = "${vgPrefix}-nix";
  #     fsType = "ext4";
  #   };

  # fileSystems."/persist" =
  #   {
  #     device = "${vgPrefix}-persist";
  #     fsType = "ext4";
  #   };

  # fileSystems."/var/log" = {
  #   fsType = "tmpfs";
  #   options = [ "size=200M" "mode=1644" ];
  # };

  # fileSystems."/var/src" =
  #   {
  #     device = "${vgPrefix}-var--src";
  #     fsType = "ext4";
  #   };

  # swapDevices =
  #   [
  #     { device = "${vgPrefix}-swap"; }
  #   ];

  # boot.kernelParams = [ "systemd.machine_id=265675a1bbc84c4d8427e8d68774a79f" ];
}
