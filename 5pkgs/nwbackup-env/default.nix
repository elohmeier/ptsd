{ writers, pass }:
# use `eval (nwbackup-env HOST)` to load environment variables
writers.writeDashBin "nwbackup-env" ''
  HOSTNAME="''${1?must provide hostname}"
  echo "export BORG_REPO=borg-$HOSTNAME@nas1.host.nerdworks.de:."
  echo "export BORG_PASSPHRASE=$(${pass}/bin/pass hosts/$HOSTNAME/nwbackup.borgkey)"
''
