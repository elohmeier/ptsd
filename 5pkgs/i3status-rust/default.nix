{ stdenv, rustPlatform, fetchFromGitHub, fetchpatch, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  #version = "0.14.1";
  version = "2020-08-08";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    #rev = "v${version}";
    rev = "a91abe34cd7fb7479563636ae006df4dca1faefc";
    sha256 = "1ibsvpaannf2y7hhscyavm8ggck6v5mc2in2j5a929v15vd7jyhn";
  };

  # left as example for fetchpatch
  # patches = [
  #   # fix forgotten Cargo.lock update in 0.14.0 release
  #   (
  #     fetchpatch {
  #       url = "https://github.com/greshake/i3status-rust/commit/7762a5c7ad668272fb8bb8409f12242094b032b8.patch";
  #       sha256 = "097f6w91cn53cj1g3bbdqm9jjib5fkb3id91jqvq88h43x14b8zb";
  #     }
  #   )
  # ];

  cargoSha256 = "0ighgy9np6zcf0lhrdlwwib440zsszcl85wbp7k4w69pqag76rbw";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
