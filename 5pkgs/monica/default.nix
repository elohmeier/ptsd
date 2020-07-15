{ stdenv, fetchurl, storagePath ? "/var/lib/monica/storage" }:

stdenv.mkDerivation rec {
  pname = "monica";
  version = "2.18.0";

  src = fetchurl {
    url = "https://github.com/monicahq/monica/releases/download/v${version}/monica-v${version}.tar.bz2";
    sha256 = "1pdhggxhxqwvh7j319m6vr7500izgjdbp1q6d1da10f7vj9z9ym1";
  };

  patches = [ ./monica-storage-path.path ];

  installPhase = ''
    mkdir -p "$out/share/monica"
    cp -R . "$out/share/monica"
    ln -s "${storagePath}/app/public" "$out/share/monica/public/storage"
  '';
}
