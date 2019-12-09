{ lib, fetchFromGitHub, buildGoPackage }:

buildGoPackage rec {
  pname = "acme-dns";
  version = "0.7.2";
  src = fetchFromGitHub {
    owner = "joohoi";
    repo = pname;
    rev = "v${version}";
    sha256 = "0wzm3kzkrw9pilravhqc9rycjxvqqqj1vwxyirx74x8r324sjjd4";
  };

  goDeps = ./deps.nix;
  goPackagePath = "github.com/joohoi/acme-dns";
}
