{ writers, symlinkJoin, borgbackup, targetHost, targetDomain ? "host.nerdworks.de" }:
let
  universe = import <ptsd/2configs/universe.nix>;

  backup-script = writers.writeDashBin "nwbackup-osx-${target}" ''
    set -e

    export BORG_REPO="borg-$(hostname)@${target}.${targetDomain}"
    export BORG_PASSCOMMAND="${pass}/bin/pass hosts/$(hostname)/nwbackup.borgkey"
    archiveName="$(hostname)-$(date +%Y-%m-%dT%H:%M:%S)"

    ${borgbackup}/bin/borg create \
      --verbose \
      --filter AME \
      --list \
      --stats \
      --show-rc \
      --compression auto,lzma,6 \
      --exclude-caches \
      --exclude '/Users/*/.cache/*' \
      --exclude '/Users/*/Applications/*' \
      --exclude '/Users/*/Library/Caches/*' \
      --exclude '/Users/*/.Trash/*' \
      --exclude '/Users/*/.DS_Store' \
      \
      ::$archiveName \
      $HOME

    ${pkgs.borgbackup}/bin/borg info "::$archiveName"
  '';

  init-script = writers.writeDashBin "nwbackup-osx-${target}-init" ''
    set -e

    export BORG_REPO="borg-$(hostname -s)@${targetHost}"
    export BORG_PASSCOMMAND="${pass}/bin/pass hosts/$(hostname -s)/nwbackup.borgkey"

    ${borgbackup}/bin/borg init -e repokey-blake2
  '';

in
symlinkJoin rec {
  name = "nwbackup-osx";
  paths = [ backup-script init-script ];
}
