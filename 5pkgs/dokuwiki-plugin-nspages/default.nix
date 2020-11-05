{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "nspages";
  src = fetchFromGitHub {
    owner = "gturri";
    repo = "nspages";
    rev = "6434d780b3208149c7090dff10c259b49c811fff";
    sha256 = "1npfrjwwy4hzzp5ibwk3pgq49wy9av04i889g59c2ysznw16l57d";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
