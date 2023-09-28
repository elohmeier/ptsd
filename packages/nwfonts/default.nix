{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "nwfonts";
  version = "1.2.0";

  src = fetchgit {
    url = "https://nas1.host.nerdworks.de:448/git/nwfonts.git";
    rev = version;
    sha256 = "sha256-TCpC9NxgC2dcoL9aMmMe4rdRbT4k18cmv32ZwrJIlKs=";
  };

  dontPatchShebangs = true;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/truetype
    cp -v fonts/*.otf $out/share/fonts/opentype
    cp -v fonts/*.{ttf,TTF} $out/share/fonts/truetype
  '';
}
