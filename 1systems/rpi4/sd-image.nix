{ config, lib, pkgs, modulesPath, ... }:
with lib;

let
  imageName = "nixos-sd-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.img";
  firmwarePartitionOffset = 8;
  firmwarePartitionID = "0x2178694e";
  firmwarePartitionName = "FIRMWARE";
  firmwareSize = 30;

  populateFirmwareCommands =
    let
      configTxt = pkgs.writeText "config.txt" ''
        [pi3]
        kernel=u-boot-rpi3.bin

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
    '';

  populateRootCommands = ''
    mkdir -p ./files/boot
    ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  '';


  rootfsImage = pkgs.callPackage ./make-ext4-fs.nix ({
    storePaths = [ config.system.build.toplevel ];
    compressImage = true;
    populateImageCommands = populateRootCommands;
    volumeLabel = "NIXOS_SD";
  });
in
{
  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/${firmwarePartitionName}";
      fsType = "vfat";
      # Alternatively, this could be removed from the configuration.
      # The filesystem is not needed at runtime, it could be treated
      # as an opaque blob instead of a discrete FAT32 filesystem.
      options = [ "nofail" "noauto" ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  system.build.sdImage = pkgs.callPackage
    ({ stdenv
     , dosfstools
     , e2fsprogs
     , mtools
     , libfaketime
     , util-linux
     , zstd
     }: stdenv.mkDerivation {
      name = imageName;

      nativeBuildInputs = [ dosfstools e2fsprogs mtools libfaketime util-linux zstd ];

      compressImage = false;

      buildCommand = ''
        mkdir -p $out/nix-support $out/sd-image
        export img=$out/sd-image/${imageName}

        echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
        if test -n "$compressImage"; then
          echo "file sd-image $img.zst" >> $out/nix-support/hydra-build-products
        else
          echo "file sd-image $img" >> $out/nix-support/hydra-build-products
        fi

        echo "Decompressing rootfs image"
        zstd -d --no-progress "${rootfsImage}" -o ./root-fs.img

        # Gap in front of the first partition, in MiB
        gap=${toString firmwarePartitionOffset}

        # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
        rootSizeBlocks=$(du -B 512 --apparent-size ./root-fs.img | awk '{ print $1 }')
        firmwareSizeBlocks=$((${toString firmwareSize} * 1024 * 1024 / 512))
        imageSize=$((rootSizeBlocks * 512 + firmwareSizeBlocks * 512 + gap * 1024 * 1024))
        truncate -s $imageSize $img

        # type=b is 'W95 FAT32', type=83 is 'Linux'.
        # The "bootable" partition is where u-boot will look file for the bootloader
        # information (dtbs, extlinux.conf file).
        sfdisk $img <<EOF
            label: dos
            label-id: ${firmwarePartitionID}

            start=''${gap}M, size=$firmwareSizeBlocks, type=b
            start=$((gap + ${toString firmwareSize}))M, type=83, bootable
        EOF

        # Copy the rootfs into the SD image
        eval $(partx $img -o START,SECTORS --nr 2 --pairs)
        dd conv=notrunc if=./root-fs.img of=$img seek=$START count=$SECTORS

        # Create a FAT32 /boot/firmware partition of suitable size into firmware_part.img
        eval $(partx $img -o START,SECTORS --nr 1 --pairs)
        truncate -s $((SECTORS * 512)) firmware_part.img
        faketime "1970-01-01 00:00:00" mkfs.vfat -i ${firmwarePartitionID} -n ${firmwarePartitionName} firmware_part.img

        # Populate the files intended for /boot/firmware
        mkdir firmware
        ${populateFirmwareCommands}

        # Copy the populated /boot/firmware into the SD image
        (cd firmware; mcopy -psvm -i ../firmware_part.img ./* ::)
        # Verify the FAT partition before copying it.
        fsck.vfat -vn firmware_part.img
        dd conv=notrunc if=firmware_part.img of=$img seek=$START count=$SECTORS

        if test -n "$compressImage"; then
            zstd -T$NIX_BUILD_CORES --rm $img
        fi
      '';
    })
    { };


}
