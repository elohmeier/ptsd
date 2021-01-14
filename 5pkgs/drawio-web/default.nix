{ stdenv, fetchFromGitHub, jdk, ant, unzip }:

stdenv.mkDerivation rec {
  pname = "drawio-web";
  version = "14.2.3";

  src = fetchFromGitHub {
    owner = "jgraph";
    repo = "drawio";
    rev = "v${version}";
    sha256 = "1nmmcr0b2408a231rj17ff3g9vqqxkwk4vx3dsqwx289arn36lz4";
  };

  buildInputs = [ jdk ant unzip ];

  buildPhase = ''
    cd etc/build
    ant war
    cd ../..
  '';

  installPhase = ''
    mkdir -p $out
    unzip build/draw.war -d $out/
  '';
}
