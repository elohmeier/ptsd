{ config, lib, pkgs, ... }:

{
  imports = [
    ./config.nix
  ];

  fileSystems."/boot" = {
    fsType = "ext4";
    device = "/dev/mmcblk2p1";
    neededForBoot = true;
  };

  fileSystems."/var/src" = {
    fsType = "ext4";
    device = "/dev/mmcblk2p2";
    neededForBoot = true;
  };

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "size=200M" "mode=1755" ];
  };

  fileSystems."/nix" = {
    fsType = "f2fs";
    device = "/dev/mmcblk2p3";
    neededForBoot = true;
  };

  boot = {
    consoleLogLevel = 7;

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

        rm /boot/nix-path-registration
      fi
    '';
  };

  services.journald.console = "/dev/ttyS2";

  console.keyMap = "us";
}
