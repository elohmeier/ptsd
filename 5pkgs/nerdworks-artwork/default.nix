{ stdenv, imagemagick, fetchgit, width ? 4096, height ? 2304 }:

stdenv.mkDerivation rec {
  pname = "nerdworks-artwork";
  version = "1.0.0";

  src = fetchgit {
    url = "https://nas1.host.nerdworks.de:448/git/ci.git";
    rev = version;
    sha256 = "1qbh262a5sz4hixbffsj75y08z9ddphsxwv40r9wvmd5qw9gw3r0";
  };
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
