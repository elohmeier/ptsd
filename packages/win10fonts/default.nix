{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "win10fonts";

  src = fetchurl {
    url = "https://www.nerdworks.de/dl/win10fonts.tar.gz";
    sha256 = "9522543e9697d14b67d98af110685a30c144a82a78a02965b607f3df730f5310";
  };

  dontPatchShebangs = true;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/truetype
    cp -v *.otf $out/share/fonts/opentype
    cp -v *.ttf $out/share/fonts/truetype
    cp -v *.TTF $out/share/fonts/truetype
  '';
}
