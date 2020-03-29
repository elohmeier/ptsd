{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "monica";
  version = "2.17.0";

  src = fetchurl {
    url = "https://github.com/monicahq/monica/releases/download/v${version}/monica-v${version}.tar.bz2";
    sha256 = "1i95sha5r4gam73dwx83hjanb815b1lfr6dya9aba7586bip9dzk";
  };

  installPhase = ''
    mkdir -p "$out/share/monica"
    cp -R . "$out/share/monica"
  '';
}
