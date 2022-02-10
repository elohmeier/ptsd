{ config, lib, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/hw/pinephone-pro
    ../../2configs/nwhost.nix
    ../../3modules/desktop
    ../../2configs/profiles/workstation
  ];

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
  };

  ptsd.nwbackup.enable = false;

  system.build.copy-to-jumpdrive =
    with config.system.build;
    let
      closureInfo = pkgs.buildPackages.closureInfo { rootPaths = toplevel; };
      extlinuxCfg = pkgs.writeText "extlinux.conf"
        ''
          timeout 50

          default NIXOS

          label NIXOS
              kernel /Image
              fdt /dtbs/rockchip/rk3399-pinephone-pro.dtb
              initrd /initrd
              append init=${toplevel}/init ${toString config.boot.kernelParams}
        '';
    in
    pkgs.writeShellScriptBin "copy-to-jumpdrive" ''
      DESTDIR="''${1?must provide destination directory}"
      echo $DESTDIR
      mkdir -p "$DESTDIR/nix/store"

      ${pkgs.rsync}/bin/rsync -av --files-from=${closureInfo}/store-paths -r / "$DESTDIR/"
      cp -v ${closureInfo}/registration "$DESTDIR/nix-path-registration"

      ${pkgs.rsync}/bin/rsync -av ${kernel}/ "$DESTDIR/boot/"
      ${pkgs.rsync}/bin/rsync -av ${initialRamdisk}/initrd "$DESTDIR/boot/"

      mkdir -p "$DESTDIR/boot/extlinux"
      cp -v ${extlinuxCfg} "$DESTDIR/boot/extlinux/extlinux.conf"
    '';


  boot.consoleLogLevel = 7;

  services.getty.autologinUser = "root";
  programs.bash.loginShellInit = ''
    ${pkgs.btop}/bin/btop
  '';

  ptsd.desktop = {
    enable = true;
  };
}
