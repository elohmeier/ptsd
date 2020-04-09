{ lib
, writers
, coreutils
, mkpasswd
, openssl
}:
let
  path = lib.makeBinPath (
    [
      coreutils
      mkpasswd
      openssl
    ]
  );
in
writers.writeDashBin "hashPassword" ''
  # usage: hashPassword [...]
  set -euf

  export PATH=${path}

  salt=$(openssl rand -base64 16 | tr -d '+=' | head -c 16)
  exec mkpasswd -m sha-512 -S "$salt" "$@"
''
