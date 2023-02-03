{ config, pkgs, ... }:

{
  imports = [
    ./sd-image.nix
    ./nix-persistent.nix
    ./hw/rpi3b_4.nix
  ];

  # reduce size
  documentation = {
    enable = false;
    man.enable = false;
    info.enable = false;
    doc.enable = false;
    dev.enable = false;
  };


  boot = {
    initrd = {
      includeDefaultModules = false;
      systemd = {
        enable = true;
        emergencyAccess = true;
      };
    };
    kernel.sysctl."vm.dirty_writeback_centisecs" = 1500; # interval between wakeups to write old data out to disk (saves power)
    #kernelPackages = pkgs.linuxPackages_rpi3;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    tmpOnTmpfs = true;
  };

  ptsd.secrets.enable = false;

  sdImage = {
    populateFirmwareCommands =
      let
        configTxt = pkgs.writeText "config.txt" ''
          [pi3]
          kernel=u-boot-rpi3.bin

          [pi4]
          kernel=u-boot-rpi4.bin
          enable_gic=1
          armstub=armstub8-gic.bin

          # Otherwise the resolution will be weird in most cases, compared to
          # what the pi3 firmware does by default.
          disable_overscan=1

          # Supported in newer board revisions
          arm_boost=1

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
      in
      ''
        fw=${pkgs.raspberrypifw}/share/raspberrypi/boot
        ${pkgs.rsync}/bin/rsync -av \
          $fw/bootcode.bin \
          $fw/fixup*.dat \
          $fw/start*.elf \
          "$NIX_BUILD_TOP/firmware/"

        # Add pi3 specific files
        ${pkgs.rsync}/bin/rsync -av ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin "$NIX_BUILD_TOP/firmware/u-boot-rpi3.bin"

        # Add pi4 specific files
        ${pkgs.rsync}/bin/rsync -av ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin "$NIX_BUILD_TOP/firmware/u-boot-rpi4.bin"
        ${pkgs.rsync}/bin/rsync -av ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin "$NIX_BUILD_TOP/firmware/armstub8-gic.bin"
        ${pkgs.rsync}/bin/rsync -av ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb "$NIX_BUILD_TOP/firmware/bcm2711-rpi-4-b.dtb"

        cp -v ${configTxt} "$NIX_BUILD_TOP/firmware/config.txt"
      '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
