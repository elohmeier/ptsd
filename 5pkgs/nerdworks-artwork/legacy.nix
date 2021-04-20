{ stdenv, imagemagick, fetchgit, width ? 4096, height ? 2304 }:

stdenv.mkDerivation rec {
  pname = "nerdworks-artwork";
  version = "1.1.1";

  src = fetchgit {
    url = "https://nas1.host.nerdworks.de:448/git/ci.git";
    rev = version;
    sha256 = "0w7ijiff9plfsfg365i6mj7v1vcnz9i76n3hm93cwqnjiaz5yhnf";
  };
  buildInputs = [ imagemagick ];
  installPhase = ''
    mkdir -p "$out/scaled"

    ${imagemagick}/bin/convert $src/os/wallpaper-n3-4096.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/wallpaper-n3.png"

    ${imagemagick}/bin/convert $src/os/wallpaper-fraam-2021-4096.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/wallpaper-fraam-2021.png"

    ${imagemagick}/bin/convert $src/os/wallpaper-fraam-2021-dark-4096.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/wallpaper-fraam-2021-dark.png"

    ${imagemagick}/bin/convert $src/os/win10lock.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/win10lock.png"
    
    cp $src/os/* $out/
  '';
}
