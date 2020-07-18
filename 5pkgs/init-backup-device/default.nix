{ lib, pkgs, symlinkJoin, writeScriptBin, writeShellScriptBin, repos ? [ ], ... }:
let
  penv =
    pkgs.python3.withPackages (pythonPackages: with pythonPackages; [ click ]);

  content = builtins.replaceStrings [ "# nix-replace #" ] [
    ''
      REPOS = ${builtins.toJSON repos}
      BORG_PATH = "${pkgs.borgbackup}/bin/borg"
      ZFS_PATH = "${pkgs.zfs}/bin/zfs"
      ZPOOL_PATH = "${pkgs.zfs}/bin/zpool"
    ''
  ]
    (builtins.readFile ./init-backup-device.py);

  script = writeScriptBin "init-backup-device" ''
    #!${penv}/bin/python3
    ${content}
  '';
in
symlinkJoin rec {
  name = "init-backup-device";
  paths = [ script ];
}
