{ stdenv, fetchurl, storagePath ? "/var/lib/monica/storage" }:

stdenv.mkDerivation rec {
  pname = "monica";
  version = "2.19.1";

  src = fetchurl {
    url = "https://github.com/monicahq/monica/releases/download/v${version}/monica-v${version}.tar.bz2";
    sha256 = "0m4gnacm0dvpbnh42y9wvr27l6vqn95ybb6b09c82bgqjcff02k3";
  };

  patches = [ ./monica-storage-path.path ];

  installPhase = ''
    mkdir -p "$out/share/monica"
    cp -R . "$out/share/monica"
    ln -s "${storagePath}/app/public" "$out/share/monica/public/storage"
  '';
}
