{ stdenv, imagemagick, fetchgit, width ? 4096, height ? 2304 }:

stdenv.mkDerivation rec {
  pname = "nerdworks-artwork";
  version = "1.1.0";

  src = fetchgit {
    url = "https://nas1.host.nerdworks.de:448/git/ci.git";
    rev = version;
    sha256 = "10qzjnqi76xma528kj6wf0ksij732d1wcv6r67g14n7b8rvj00sw";
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

    ${imagemagick}/bin/convert $src/os/win10lock.png -resize \
      ${toString width}x${toString height}^ \
      "$out/scaled/win10lock.png"
    
    cp $src/os/* $out/
  '';
}
