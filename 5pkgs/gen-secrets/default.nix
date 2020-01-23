{ pkgs }:
pkgs.writeDashBin "gen-secrets" ''
  HOSTNAME="''${1?must provide hostname}"
  TMPDIR=$(${pkgs.coreutils}/bin/mktemp -d)
  PASSWORD=$(${pkgs.pwgen}/bin/pwgen 25 1)
  HASHED_PASSWORD=$(echo $PASSWORD | ${pkgs.hashPassword}/bin/hashPassword -s) > /dev/null

  ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -f $TMPDIR/ssh.id_ed25519 -P "" -C "" >/dev/null
  ${pkgs.wireguard}/bin/wg genkey > $TMPDIR/nwvpn.key
  ${pkgs.coreutils}/bin/cat $TMPDIR/nwvpn.key | ${pkgs.wireguard}/bin/wg pubkey > $TMPDIR/nwvpn.pub
  ${pkgs.pwgen}/bin/pwgen 25 1 > $TMPDIR/nwbackup.borgkey
  ${pkgs.dropbear}/bin/dropbearkey -t ecdsa -f $TMPDIR/initrd-ssh-key

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
      cores = 1;
      nets = {
        nwvpn = {
          ip4.addr = "changeme";
          aliases = [
            "$HOSTNAME.nw"
          ];
          wireguard.pubkey = ${"''"}
  $(cat $TMPDIR/nwvpn.pub)
          ${"''"};
        };
      };
      ssh.privkey.path = <secrets/ssh.id_ed25519>;
      ssh.pubkey = "$(cat $TMPDIR/ssh.id_ed25519.pub)";
    };
  EOF

  rm -rf $TMPDIR
''
