{ config, lib, pkgs, ... }:
with lib;

let
  imageName = "nixos-sd-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.img";
  firmwarePartitionOffset = 8;
  firmwarePartitionID = "0x2178694e";
  firmwarePartitionName = "FIRMWARE";
  firmwareSize = 200; # in MB

  rootfsImage = pkgs.callPackage ./make-ext4-fs.nix {
    compressImage = true;
    populateImageCommands = config.sdImage.populateRootCommands;
    storePaths = [ config.system.build.toplevel ];
    storeRoot = "/store";
    volumeLabel = "NIXOS_SD";
  };
in
{
  options.sdImage = {
    populateFirmwareCommands = mkOption {
      example = literalExpression "'' cp \${pkgs.myBootLoader}/u-boot.bin firmware/ ''";
      description = ''
        Shell commands to populate the ./firmware directory.
        All files in that directory are copied to the
        /boot/firmware partition on the SD image.
      '';
    };

    populateRootCommands = mkOption {
      example = literalExpression "''\${config.boot.loader.generic-extlinux-compatible.populateCmd} -c \${config.system.build.toplevel} -d ./files/boot''";
      description = ''
        Shell commands to populate the ./files directory.
        All files in that directory are copied to the
        root (/) partition on the SD image. Use this to
        populate the ./files/boot (/boot) directory.
      '';
    };
  };

  config = {

    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/${firmwarePartitionName}";
        fsType = "vfat";
        # Alternatively, this could be removed from the configuration.
        # The filesystem is not needed at runtime, it could be treated
        # as an opaque blob instead of a discrete FAT32 filesystem.
        options = [ "noatime" "nofail" "noauto" ];
      };
      "/nix" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "nodev" "noatime" "commit=1800" ];
      };
      "/" = {
        fsType = "tmpfs";
        options = [ "mode=1755" ];
      };
      "/boot" = {
        device = "/nix/boot";
        options = [ "bind" ];
      };
    };

    boot.postBootCommands = ''
      # On the first boot do some maintenance tasks
      if [ -f /nix/nix-path-registration ]; then
        set -euo pipefail
        set -x
        # Figure out device names for the boot device and root filesystem.
        rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /nix)
        bootDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

        # Resize the root partition and the filesystem to fit the disk
        echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /nix/nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

        # Prevents this from running on later boots.
        rm -f /nix/nix-path-registration
      fi
    '';

    services.journald.extraConfig = "Storage=volatile";

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
          ${config.sdImage.populateFirmwareCommands}

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

  };
}
