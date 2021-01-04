{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "traefik-forward-auth";
  version = "2.2.0";

  vendorSha256 = "031g9ldpnmwxhxgnbnzn5slxsy75mprzdwsk1svnpd3lsz8h29mr";

  src = fetchFromGitHub {
    owner = "thomseddon";
    repo = pname;
    rev = "v${version}";
    sha256 = "10may7zmih3fabkrm6nf5d5jb5g9q9k6i7a8563raxs5933qhipr";
  };
}
