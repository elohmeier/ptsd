{ writers, borgbackup, targetHost, targetDomain ? "host.nerdworks.de" }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
writers.writeDashBin "nwbackup-osx-${target}" ''
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
''
