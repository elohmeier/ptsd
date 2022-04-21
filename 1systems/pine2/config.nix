{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/hw/pinephone-pro
    ../../2configs/nwhost.nix
    ../../2configs/stateless-root.nix
    ../../3modules/desktop
    ../../2configs/profiles/workstation
    ../../2configs/nixbuild.nix

    ./modules/syncthing.nix
  ];

  ptsd.nwacme.hostCert.enable = false;
  ptsd.tor-ssh.enable = false;

  networking = {
    hostName = "pine2";
    useNetworkd = true;
    useDHCP = false;
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };
    firewall.enable = false; # todo: kernel module missing?
  };

  ptsd.nwbackup.paths = [
    "/home/enno/"
  ];

  system.build.format-disk = pkgs.writeShellScriptBin "format-disk" ''
    DISK="''${1?must provide a block device, e.g. /dev/sda}"
    
    # partition disk
    ${pkgs.parted}/sbin/parted --script $DISK \
      mklabel gpt \
      mkpart "boot" ext4 1MiB 1000MiB \
      mkpart "var-src" ext4 1000MiB 1050MiB \
      mkpart "nix" ext4 1050MiB 100%

    # format partitions
    ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L boot ''${DISK}1 || exit 1
    ${pkgs.e2fsprogs}/bin/mkfs.ext4 -L var-src ''${DISK}2 || exit 1
    ${pkgs.f2fs-tools}/bin/mkfs.f2fs -f -l nix ''${DISK}3 || exit 1
  '';

  system.build.mount-sdcard = pkgs.writeShellScriptBin "mount-sdcard" ''
    DISK="''${1?must provide a block device, e.g. /dev/sda}"
    DIR="''${2?must provide a directory, e.g. /mnt/sd}"
    
    mkdir -p $DIR/{boot,nix/store,var/src}
    mount ''${DISK}1 $DIR/boot
    mount ''${DISK}2 $DIR/var/src
    mount ''${DISK}3 $DIR/nix
  '';

  system.build.copy-to-dir =
    with config.system.build;
    let
      closureInfo = pkgs.buildPackages.closureInfo { rootPaths = [ toplevel ]; };
      extlinuxBoot = pkgs.runCommand "extlinux-boot" { } ''
        mkdir -p $out
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d $out
      '';
    in
    pkgs.writeShellScriptBin "copy-to-dir" ''
      DESTDIR="''${1?must provide destination directory}"
      mkdir -p "$DESTDIR/nix/store"

      rsync -av --files-from=${closureInfo}/store-paths -r --delete / "$DESTDIR/"
      rsync -av --delete ${extlinuxBoot}/ "$DESTDIR/boot/"
      cp -v ${closureInfo}/registration "$DESTDIR/boot/nix-path-registration"
    '';

  ptsd.desktop = {
    enable = true;
    modifier = "Mod1";
    fontSize = 12.0;
  };

  home-manager.users.mainUser = { pkgs, ... }: {
    wayland.windowManager.sway.config = {
      input."0:0:kb151" = {
        xkb_layout = "us";
        repeat_delay = "500";
        repeat_rate = "15";
      };
      input."1046:1158:Goodix_Capacitive_TouchScreen".map_to_output = "DSI-1";
      output.DSI-1 = {
        transform = "90";
      };
    };
  };
}
