# Raspberry Pi 3B+

{ config, pkgs, lib, ... }:
{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! Otherwise (even if you have a Raspberry Pi 2 or 3), pick this:
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  boot.kernelParams = [ "cma=32M" ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  nix.maxJobs = 4;

  # !!! Adding a swap file is optional, but strongly recommended!
  # swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (
      pkgs.stdenv.mkDerivation {
        name = "broadcom-rpi3bplus-extra";
        src = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/b518de4/brcm/brcmfmac43455-sdio.txt";
          sha256 = "0r4bvwkm3fx60bbpwd83zbjganjnffiq1jkaj0h20bwdj9ysawg9";
        };
        phases = [ "installPhase" ];
        installPhase = ''
          mkdir -p $out/lib/firmware/brcm
          cp $src $out/lib/firmware/brcm/brcmfmac43455-sdio.txt
        '';
      }
    )
  ];

  # reduce size
  environment.noXlibs = true;
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };
}
