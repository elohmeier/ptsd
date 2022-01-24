{ config
, lib
, pkgs
, ...
}:

{
  imports = [
    ./config.nix
  ];

  fileSystems = {
    "/" = {
      device = "/dev/mapper/luks-root";
      fsType = "f2fs";
      encrypted = {
        enable = true;
        blkDev = "/dev/disk/by-path/platform-1c11000.mmc-part4";
        label = "luks-root";
      };
    };
    # "/boot" = { device = "/dev/disk/by-path/platform-1c11000.mmc-part3"; fsType = "ext4"; };
  };

  system.stateVersion = "21.11";

  # mount e.g. root to /jumpdrive/ folder and boot to /jumpdrive/boot folder & then run this script using
  # sudo nix run .#nixosConfigurations.pine1.config.system.build.copy-to-jumpdrive /jumpdrive
  system.build.copy-to-jumpdrive =
    let
      closureInfo = pkgs.buildPackages.closureInfo { rootPaths = config.system.build.toplevel; };
      inherit (config.mobile.outputs) stage-0;
      kernel = stage-0.mobile.boot.stage-1.kernel.package;
      kernel_file = "${kernel}/${kernel.file}";
    in
    pkgs.writeShellScriptBin "copy-to-jumpdrive" ''
      DESTDIR="''${1?must provide destination directory}"
      echo $DESTDIR

      while IFS= read -r path; do
        echo "copying $path"
        ${pkgs.rsync}/bin/rsync -a "$path" "$DESTDIR/nix/store/"
      done < "${closureInfo}/store-paths"
      cp -v ${closureInfo}/registration "$DESTDIR/nix-path-registration"

      cp -v ${stage-0.mobile.outputs.initrd} "$DESTDIR/boot/mobile-nixos/boot/stage-1"
      cp -v ${kernel_file} "$DESTDIR/boot/mobile-nixos/boot/kernel"
      ${pkgs.rsync}/bin/rsync -a ${kernel}/dtbs "$DESTDIR/boot/mobile-nixos/boot/"
      cp -v ${stage-0.mobile.outputs.initrd} "$DESTDIR/boot/mobile-nixos/recovery/stage-1"
      cp -v ${kernel_file} "$DESTDIR/boot/mobile-nixos/recovery/kernel"
      ${pkgs.rsync}/bin/rsync -a ${kernel}/dtbs "$DESTDIR/boot/mobile-nixos/recovery/"
    '';

  networking = {
    useNetworkd = true;
    useDHCP = false;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };

    wireless.iwd.enable = true;

    # missing kernel module?
    # firewall.enable = false;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.udev.packages = [ pkgs.sxmo-utils ];
  systemd.services.sxmo-setpermissions = {
    description = "Set device-specific permissions for sxmo";
    wantedBy = [
      "multi-user.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.sxmo-utils}/bin/sxmo_setpermissions.sh";
    };
  };
}
