{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "2020-05-11";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "207497ad0987f969442e27376fedc12a80074a41";
    sha256 = "1b74dnglnvvaavj6pcmmj4854ya2panvygvhn73sjxnwkb727hr3";
  };

  cargoSha256 = "0jdwcyw4bx7fcrscfarlvlbp2jaajmjabkw2a3w3ld07dchq0wb0";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
