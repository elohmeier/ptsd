{ stdenv, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "traggo";
  version = "0.2.0";
  src = fetchurl {
    url = "https://github.com/traggo/server/releases/download/v${version}/traggo-server-${version}-linux-amd64.zip";
    sha256 = "0q42qrz62dkqjd7hdiswgajh5rynkvvvvi6hq3h5i2l8n176f2ka";
  };
  setSourceRoot = "sourceRoot=`pwd`";
  buildInputs = [ unzip ];
  installPhase = ''
    mkdir -p $out/bin
    cp traggo-server-${version}-linux-amd64 $out/bin/traggo
  '';
}
