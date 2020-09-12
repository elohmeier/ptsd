{ stdenv, rustPlatform, fetchFromGitHub, fetchpatch, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  #version = "0.14.1";
  version = "2020-09-08";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    #rev = "v${version}";
    rev = "df1974dd313f6b50bf0f19f948698fc6cb20e8f3";
    sha256 = "02q11a4ggackvdv8ls6cmiw5mjfnrb8505q4syfwfs0g5l4lhyjy";
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

  cargoSha256 = "1h1fjjp019b2gbmr0dhyd6d0kbzmf8l4zyan5c5hcmlajrdv10bi";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
