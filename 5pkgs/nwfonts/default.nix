{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  pname = "nwfonts";
  version = "1.0.0";

  src = fetchgit {
    url = "https://nas1.host.nerdworks.de:448/git/nwfonts.git";
    rev = version;
    sha256 = "1yalkq7wrl7m7z7cpriqwri8adsssdxiai748hbi9rbmn2q875qn";
  };

  dontPatchShebangs = true;

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/truetype
    cp -v fonts/*.otf $out/share/fonts/opentype
    cp -v fonts/*.{ttf,TTF} $out/share/fonts/truetype
  '';
}
