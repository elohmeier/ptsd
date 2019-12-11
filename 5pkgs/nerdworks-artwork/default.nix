{ stdenv, imagemagick, fetchurl, width ? 4096, height ? 2304 }:
stdenv.mkDerivation rec {
  name = "nerdworks-artwork";

  src = fetchurl {
    url = "https://www.nerdworks.de/dl/nw-artwork.tgz";
    sha256 = "0jjn2yzgf2vrw7pq2nj3268njra4fgqiap02f1nyrx9xbnkgwwkk";
  };

  buildInputs = [ imagemagick ];
  installPhase = ''
    mkdir -p "$out/scaled"
    ${imagemagick}/bin/convert wallpaper-n3-4096.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/wallpaper-n3.png"

    ${imagemagick}/bin/convert win10lock.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/win10lock.png"
    
    cp Logo_Farbe_Ohne_Schrift_500.png "$out/Logo_Farbe_Ohne_Schrift_500.png"
  '';
}
