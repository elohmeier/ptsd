{ config, lib, pkgs, ... }:

{
  imports = [
    #../../2configs/nixbuild.nix
    #../../2configs/profiles/workstation
    ../../2configs
    ../../2configs/fish.nix
    ../../2configs/hw/pinephone-pro
    ../../2configs/nwhost-mini.nix
    ../../2configs/stateless-root.nix
    ../../2configs/users/enno.nix

    ./modules/syncthing.nix
  ];

  # as recommended by https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl."fs.inotify.max_user_watches" = 204800;

  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = with pkgs;[
    git
    home-manager
  ];

  programs.sway.enable = true;

  ptsd.nwacme.hostCert.enable = false;

  ptsd.tailscale.enable = true;

  networking = {
    hostName = "pine2";
    useNetworkd = true;
    useDHCP = false;
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      plugins = lib.mkForce [ ];
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };
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

  system.stateVersion = "21.11";
}
