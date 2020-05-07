{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "2020-05-05";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "2efa54c39fa56613ecfe77b34a7cb248bc783de0";
    sha256 = "03v323yznsi74rzs8in40hg6arvsbli88rmmswyinmwd8043mvnr";
  };

  cargoSha256 = "0jdwcyw4bx7fcrscfarlvlbp2jaajmjabkw2a3w3ld07dchq0wb0";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
