{ pkgs }:
pkgs.writeDashBin "gen-secrets" ''
  HOSTNAME="''${1?must provide hostname}"
  TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
  PASSWORD=$(${pkgs.pwgen}/bin/pwgen 25 1)
  HASHED_PASSWORD=$(echo $PASSWORD | ${pkgs.hashPassword}/bin/hashPassword -s) > /dev/null

  ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f $TMPDIR/ssh.id_ed25519 -P "" -C "" >/dev/null
  ${pkgs.wireguard}/bin/wg genkey > $TMPDIR/nwvpn.key 2>/dev/null
  ${pkgs.coreutils}/bin/cat $TMPDIR/nwvpn.key | ${pkgs.wireguard}/bin/wg pubkey > $TMPDIR/nwvpn.pub
  ${pkgs.pwgen}/bin/pwgen 25 1 > $TMPDIR/nwbackup.borgkey
  ${pkgs.dropbear}/bin/dropbearkey -t ecdsa -f $TMPDIR/initrd-ssh-key > /dev/null 2>/dev/null
  ${pkgs.openssl}/bin/openssl ecparam -name secp384r1 -genkey -noout -out $TMPDIR/syncthing.key 2>/dev/null > /dev/null
  ${pkgs.openssl}/bin/openssl req -new -x509 -key $TMPDIR/syncthing.key -out $TMPDIR/syncthing.crt -days 10000 -subj "/CN=syncthing" 2>/dev/null > /dev/null

  cat <<EOF > $TMPDIR/hashedPasswords.nix
  {
    root = "$HASHED_PASSWORD";
    mainUser = "$HASHED_PASSWORD";
  }
  EOF

  cd $TMPDIR
  for x in *; do
    ${pkgs.coreutils}/bin/cat $x | ${pkgs.pass}/bin/pass insert -m hosts/$HOSTNAME/$x > /dev/null
  done
  echo $PASSWORD | ${pkgs.pass}/bin/pass insert -m admin/$HOSTNAME/pass > /dev/null

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
    ssh.privkey.path = <secrets/ssh.id_ed25519>;
    ssh.pubkey = "$(cat $TMPDIR/ssh.id_ed25519.pub)";
    syncthing.id = "$(${pkgs.syncthing-device-id}/bin/syncthing-device-id $TMPDIR/syncthing.crt)";
  };
  EOF

  rm -rf $TMPDIR
''
