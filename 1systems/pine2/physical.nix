{ config, lib, pkgs, ... }:

{
  imports = [
    ./config.nix
  ];

  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "size=200M" "mode=1755" ];
  };

  fileSystems."/boot" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/boot";
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    fsType = "f2fs";
    device = "/dev/disk/by-label/nix";
    neededForBoot = true;
  };

  fileSystems."/var/src" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/var-src";
    neededForBoot = true;
  };

  boot = {
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

  console.keyMap = "us";
}
