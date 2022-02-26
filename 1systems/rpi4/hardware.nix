{ config, lib, pkgs, ... }: {

  imports = [
    ../../2configs/sd-image.nix
  ];

  hardware.raspberry-pi."4".audio.enable = true;
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  # save space
  # hardware.enableRedistributableFirmware = lib.mkForce false;
  # hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];
  # hardware.wirelessRegulatoryDatabase = true;
  # services.udisks2.enable = false;

  sdImage = {
    populateFirmwareCommands =
      let
        configTxt = pkgs.writeText "config.txt" ''
          [pi4]
          kernel=Image
          initramfs initrd
          enable_gic=1
          armstub=armstub8-gic.bin

          # Otherwise the resolution will be weird in most cases, compared to
          # what the pi3 firmware does by default.
          disable_overscan=1

          # GPU/Display config
          dtoverlay=vc4-fkms-v3d
          gpu_mem=128

          dtoverlay=hifiberry-dacplus

          [all]
          # Boot in 64-bit mode.
          arm_64bit=1

          # required for Carberry
          enable_uart=1

          # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
          # when attempting to show low-voltage or overtemperature warnings.
          avoid_warnings=1
        '';

        cmdlineTxt = pkgs.writeText "cmdline.txt" "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}";
      in
      ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

        # Add the config / cmdline
        cp ${configTxt} firmware/config.txt
        cp ${cmdlineTxt} firmware/cmdline.txt

        # Add pi4 specific files
        cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/

        # Add kernel & initrd
        cp -r ${config.system.build.kernel}/Image firmware/
        cp -r ${config.system.build.kernel}/dtbs/* firmware/
        cp -r ${config.system.build.initialRamdisk}/initrd firmware/
      '';
  };
}
