{ stdenv, fetchurl, storagePath ? "/var/lib/monica/storage" }:

stdenv.mkDerivation rec {
  pname = "monica";
  version = "3.0.1";

  src = fetchurl {
    url = "https://github.com/monicahq/monica/releases/download/v${version}/monica-v${version}.tar.bz2";
    sha256 = "sha256-VJJqJAnQgFghGw7iGkysCxzlBq/omYKLqfBlLrS6GzE=";
  };

  patches = [ ./monica-storage-path.path ];

  installPhase = ''
    mkdir -p "$out/share/monica"
    cp -R . "$out/share/monica"
    ln -s "${storagePath}/app/public" "$out/share/monica/public/storage"
  '';
}
