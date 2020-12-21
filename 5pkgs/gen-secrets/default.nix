{ writers, coreutils, pwgen, hashPassword, openssh, wireguard, openssl, pass, syncthing-device-id }:
writers.writeDashBin "gen-secrets" ''
  HOSTNAME="''${1?must provide hostname}"
  TMPDIR=$(${coreutils}/bin/mktemp -d)
  PASSWORD=$(${pwgen}/bin/pwgen 25 1)
  HASHED_PASSWORD=$(echo $PASSWORD | ${hashPassword}/bin/hashPassword -s) > /dev/null

  ${openssh}/bin/ssh-keygen -t ed25519 -f $TMPDIR/ssh.id_ed25519 -P "" -C "" >/dev/null
  ${openssh}/bin/ssh-keygen -t ed25519 -f $TMPDIR/nwbackup.id_ed25519 -P "" -C "" >/dev/null
  ${wireguard}/bin/wg genkey > $TMPDIR/nwvpn.key 2>/dev/null
  ${coreutils}/bin/cat $TMPDIR/nwvpn.key | ${wireguard}/bin/wg pubkey > $TMPDIR/nwvpn.pub
  ${pwgen}/bin/pwgen 25 1 > $TMPDIR/nwbackup.borgkey
  ${openssl}/bin/openssl ecparam -name secp384r1 -genkey -noout -out $TMPDIR/syncthing.key 2>/dev/null > /dev/null
  ${openssl}/bin/openssl req -new -x509 -key $TMPDIR/syncthing.key -out $TMPDIR/syncthing.crt -days 10000 -subj "/CN=syncthing" 2>/dev/null > /dev/null

  cat <<EOF > $TMPDIR/hashedPasswords.nix
  {
    root = "$HASHED_PASSWORD";
    mainUser = "$HASHED_PASSWORD";
  }
  EOF

  cd $TMPDIR
  for x in *; do
    ${coreutils}/bin/cat $x | ${pass}/bin/pass insert -m hosts/$HOSTNAME/$x > /dev/null
  done
  echo $PASSWORD | ${pass}/bin/pass insert -m admin/$HOSTNAME/pass > /dev/null

  cat <<EOF
  $HOSTNAME = {
    nets = {
      nwvpn = {
        ip4.addr = "changeme";
        aliases = [
          "$HOSTNAME.nw"
        ];
        wireguard.pubkey = "$(cat $TMPDIR/nwvpn.pub)";
      };
    };
    borg.pubkey = "$(cat $TMPDIR/nwbackup.id_ed25519.pub)";
    ssh.privkey.path = <secrets/ssh.id_ed25519>;
    ssh.pubkey = "$(cat $TMPDIR/ssh.id_ed25519.pub)";
    syncthing.id = "$(${syncthing-device-id}/bin/syncthing-device-id $TMPDIR/syncthing.crt)";
  };
  EOF

  rm -rf $TMPDIR
''
