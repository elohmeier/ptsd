{ lib, writers, symlinkJoin, cryptsetup }:
with lib;
let
  ws1 = import ../../1systems/ws1/physical.nix { };
  ws2 = import ../../1systems/ws2/physical.nix { };

  cryptOpen = cfg: mapAttrsToList (name: opts: "${cryptsetup}/bin/cryptsetup luksOpen \"${opts.device}\" \"${name}\"") cfg.boot.initrd.luks.devices;
  cryptClose = cfg: mapAttrsToList (name: _opts: "${cryptsetup}/bin/cryptsetup luksClose \"${name}\"") cfg.boot.initrd.luks.devices;
  mount = cfg: mapAttrsToList (mountpoint: opts: "mount ${opts.device} /mnt${mountpoint}") (filterAttrs (_: hasAttr "device") cfg.fileSystems);
  umount = cfg: mapAttrsToList (mountpoint: _opts: "umount /mnt${mountpoint}") (filterAttrs (_: hasAttr "device") cfg.fileSystems);
  mkdir = cfg: mapAttrsToList (mountpoint: _opts: "mkdir -p /mnt${mountpoint}") cfg.fileSystems;

  up = cfg: name:
    writers.writeDashBin "ptsdbootstrap-${name}-up"
      ''
        set -e

        ${concatStringsSep "\n" (cryptOpen cfg)}

        vgchange -ay

        ${optionalString (!hasAttr "device" cfg.fileSystems."/") concatStringsSep "\n" (mkdir cfg)}

        ${concatStringsSep "\n" (mount cfg)}
      '';

  down = cfg: name:
    writers.writeDashBin "ptsdbootstrap-${name}-down"
      ''
        set -e

        ${concatStringsSep "\n" (umount cfg)}

        # TODO vgchange -an $vgname

        ${concatStringsSep "\n" (cryptClose cfg)}
      '';
in
symlinkJoin {
  name = "ptsdbootstrap";
  paths = [
    (up ws1 "ws1")
    (up ws2 "ws2")
    (down ws1 "ws1")
    (down ws2 "ws2")
  ];
}
