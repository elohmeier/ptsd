{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "2020-05-24";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "f642798369a617fd0ebf8b8efa92864695fa9fcb";
    sha256 = "0cgvmwyx227hx57wkxzcrfb03alz710gv4h23hdb31j68lk6k08x";
  };

  cargoSha256 = "1g1k4fvpryr9fpbg6s3wfsr1z6ia8blsbysfdr6i50sbh796f2fz";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
