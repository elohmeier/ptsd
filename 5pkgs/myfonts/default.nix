{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "myfonts";

  src = fetchurl {
    url = "https://www.nerdworks.de/dl/fonts.tgz";
    sha256 = "1vsawm8n6vxi4zr1w2gmham80kv4mlsffqszqafqgnfrwzcb499w";
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
