{ stdenv, fetchurl, storagePath ? "/var/lib/monica/storage" }:

stdenv.mkDerivation rec {
  pname = "monica";
  version = "3.7.0";

  src = fetchurl {
    url = "https://github.com/monicahq/monica/releases/download/v${version}/monica-v${version}.tar.bz2";
    sha256 = "sha256-YqGGMXRRqPnji9NoQTqX80lYaFxnANQ+WgIaYBedU+4=";
  };

  patches = [ ./monica-storage-path.path ];

  installPhase = ''
    mkdir -p "$out/share/monica"
    cp -R . "$out/share/monica"
    ln -s "${storagePath}/app/public" "$out/share/monica/public/storage"
  '';
}
