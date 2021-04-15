{ writers, pass, qrencode }:
let
  universe = import ../../2configs/universe.nix;
in
writers.writeDashBin "nwvpn-plain" ''
  set -e
  HOSTNAME="''${1?must provide hostname}"
  IP="''${2?must provide IP address}"
  PASSWORD=$(${pass}/bin/pass hosts/$HOSTNAME/nwvpn.key)

  cat <<EOF
  [Interface]
  Address = $IP/24
  PrivateKey = $PASSWORD

  [Peer]
  PublicKey = ${universe.hosts.htz1.nets.nwvpn.wireguard.pubkey}
  Endpoint = htz1.host.nerdworks.de:55555
  AllowedIPs = 191.18.19.0/24
  PersistentKeepalive = 21
  EOF
''
