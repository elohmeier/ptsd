{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "myfonts";

  src = fetchurl {
    url = "https://www.nerdworks.de/dl/fonts.tgz";
    sha256 = "875cff57f73ba497298f6792cc5425d77d91c3f833eb8200e2cb8c60a0185568";
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
