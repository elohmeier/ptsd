(
  { config, pkgs, ... }:
  {
    # needed:
    # modules = [
    #   nixos-hardware.nixosModules.raspberry-pi-4
    #   ./2configs/rescue.nix
    #   ./2configs/hw/rpi3b_4.nix
    # ];

    # the result can be copied to a fat32-formatted sd card
    system.build.sdroot =
      let
        configTxt = pkgs.writeText "config.txt" ''
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
        toplevel-squashfs = pkgs.runCommand "toplevel-netboot" { } ''
          mkdir $out
          cp ${config.system.build.toplevel}/{kernel-params,nixos-version} $out/
          ln -s ${config.system.build.kernel}/Image $out/kernel
          ln -s ${config.system.build.netbootRamdisk}/initrd $out/initrd
          ln -s ${config.hardware.deviceTree.package} $out/dtbs
        '';
      in
      pkgs.runCommand "rescue-rpi4-sdroot" { } ''
        mkdir -p $out
        cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/{bootcode.bin,fixup*.dat,start*.elf,bcm2711-rpi-4-b.dtb} $out/
        cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/
        cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin $out/u-boot-rpi4.bin
        cp ${configTxt} $out/config.txt
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${toplevel-squashfs} -d $out
      '';

    # see https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    nixpkgs.overlays = [
      (_final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

  }
)
