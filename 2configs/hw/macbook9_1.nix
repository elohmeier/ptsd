{ config, lib, pkgs, ... }:

# we need at least linux kernel 5.3
# ref. https://github.com/roadrunner2/macbook12-spi-driver/blob/touchbar-driver-hid-driver/README.md
{
  imports = [
    <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
  ];

  # TODO: test if kernelParams work.
  # applespi is required for keyboard/touchpad support
  boot.initrd.kernelModules = [ "applespi" ];
  boot.kernelParams = [
    "applespi.fnmode=2" # enable function keys by default instead of media keys
    "applespi.iso_layout=0" # switch wrong keymappings
  ];

  # speaker unsupported in current linux kernel (as of 5.4)
  # ref. https://bugzilla.kernel.org/show_bug.cgi?id=110561
  # potential driver: https://github.com/leifliddy/macbook12-audio-driver
  # apply the driver patch here. this enables the internal speaker, 
  # *BUT* kills the internal microphone and headphone jack support
  boot.kernelPatches = [
    {
      name = "macbook12-audio-driver";
      patch = ./patches/linux_5.4_m12ad_20200223.patch;
    }
  ];
}
