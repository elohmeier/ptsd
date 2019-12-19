{ stdenv, imagemagick, fetchurl, width ? 4096, height ? 2304 }:
stdenv.mkDerivation rec {
  name = "nerdworks-artwork";

  src = <ci>;

  dontUnpack = true;

  buildInputs = [ imagemagick ];
  installPhase = ''
    mkdir -p "$out/scaled"

    ${imagemagick}/bin/convert $src/os/wallpaper-n3-4096.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/wallpaper-n3.png"

    ${imagemagick}/bin/convert $src/os/win10lock.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/win10lock.png"
    
    cp $src/os/* $out/
  '';
}
