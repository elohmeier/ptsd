{ writers, borgbackup, pass, targetName, targetHost }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
writers.writeDashBin "nwbackup-osx-${targetName}" ''
  set -e

  export BORG_REPO="borg-$(hostname -s)@${targetHost}:."
  export BORG_PASSCOMMAND="${pass}/bin/pass hosts/$(hostname -s)/nwbackup.borgkey"
  archiveName="$(hostname -s)-$(date +%Y-%m-%dT%H:%M:%S)"

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

  ${borgbackup}/bin/borg info "::$archiveName"
''
