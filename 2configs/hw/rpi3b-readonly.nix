{ config, lib, pkgs, ... }:

{
  zramSwap = {
    enable = true;
    numDevices = 1;
    swapDevices = 1;
    memoryPercent = 75;
    algorithm = "zstd";
  };

  # reduce size
  environment.noXlibs = true;
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };
  hardware.enableRedistributableFirmware = false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];
  hardware.wirelessRegulatoryDatabase = true;
  services.udisks2.enable = false;
  security.polkit.enable = false;

  fileSystems."/" =
    {
      fsType = "tmpfs";
      options = [ "size=200M" "mode=1755" ];
    };

  fileSystems."/boot" =
    {
      fsType = "vfat";
      device = "/dev/disk/by-label/boot";
      options = [ "ro" ];
      neededForBoot = true;
    };

  fileSystems."/nix/.ro-store" = {
    fsType = "f2fs";
    device = "/dev/disk/by-label/nix-store";
    options = [ "ro" ];
    neededForBoot = true;
  };

  fileSystems."/nix/.rw-store" = {
    fsType = "tmpfs";
    options = [ "mode=0755" ];
    neededForBoot = true;
  };

  fileSystems."/nix/store" = {
    fsType = "overlay";
    device = "overlay";
    options = [
      "lowerdir=/nix/.ro-store"
      "upperdir=/nix/.rw-store/store"
      "workdir=/nix/.rw-store/work"
    ];
    depends = [
      "/nix/.ro-store"
      "/nix/.rw-store/store"
      "/nix/.rw-store/work"
    ];
  };

  fileSystems."/var/src" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/var-src";
    options = [ "ro" ];
    neededForBoot = true;
  };

  system.build.format-sdcard = pkgs.writeShellScriptBin "format-sdcard" ''
    DISK="''${1?must provide a block device, e.g. /dev/sda}"
    
    # partition disk
    ${pkgs.parted}/sbin/parted --script $DISK \
      mklabel msdos \
      mkpart primary fat32 1MiB 100MiB \
      mkpart primary ext4 100MiB 150MiB \
      mkpart primary ext4 150MiB 100%

    # format partitions
    ${pkgs.dosfstools}/bin/mkfs.vfat -n boot ''${DISK}1 || exit 1
    ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L var-src ''${DISK}2 || exit 1
    ${pkgs.f2fs-tools}/bin/mkfs.f2fs -f -l nix-store ''${DISK}3 || exit 1
  '';

  system.build.mount-sdcard = pkgs.writeShellScriptBin "mount-sdcard" ''
    DISK="''${1?must provide a block device, e.g. /dev/sda}"
    DIR="''${2?must provide a directory, e.g. /mnt/sd}"
    
    mkdir -p $DIR/{boot,nix/store,var/src}
    mount ''${DISK}1 $DIR/boot
    mount ''${DISK}2 $DIR/var/src
    mount ''${DISK}3 $DIR/nix/store
  '';

  system.build.copy-to-dir = with config.system.build; let
    closureInfo = pkgs.buildPackages.closureInfo { rootPaths = [ toplevel ]; };
    configTxt = pkgs.writeText "config.txt" ''
      [pi3]
      kernel=u-boot.bin

      [all]
      # Boot in 64-bit mode.
      arm_64bit=1

      # U-Boot needs this to work, regardless of whether UART is actually used or not.
      # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
      # a requirement in the future.
      enable_uart=1
      
      # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
      # when attempting to show low-voltage or overtemperature warnings.
      avoid_warnings=1
    '';

    cmdlineTxt = pkgs.writeText "cmdline.txt" "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}";

    extlinuxBoot = pkgs.runCommand "extlinux-boot" { } ''
      mkdir -p $out
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d $out
    '';
  in
  pkgs.writeShellScriptBin "copy-to-dir" ''
    DESTDIR="''${1?must provide destination directory}"
    mkdir -p "$DESTDIR/nix/store"

    ${pkgs.rsync}/bin/rsync -av --files-from=${closureInfo}/store-paths -r / "$DESTDIR/"
    cp -v ${closureInfo}/registration "$DESTDIR/boot/nix-path-registration"

    fw=${pkgs.raspberrypifw}/share/raspberrypi/boot

    ${pkgs.rsync}/bin/rsync -av \
      $fw/bootcode.bin \
      $fw/fixup*.dat \
      $fw/start*.elf \
      "$DESTDIR/boot/"

    ${pkgs.rsync}/bin/rsync -av ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin "$DESTDIR/boot/"

    cp -v ${configTxt} "$DESTDIR/boot/config.txt"

    ${pkgs.rsync}/bin/rsync -av ${extlinuxBoot}/ "$DESTDIR/boot/"
  '';

  boot = {
    initrd = {
      availableKernelModules = [ "overlay" ];
      kernelModules = [ "overlay" ];
      includeDefaultModules = false;
    };
    kernelPackages = pkgs.linuxPackages_rpi3;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    postBootCommands = ''
      if [ -f /boot/nix-path-registration ]; then
        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /boot/nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
      fi
    '';
  };
}
