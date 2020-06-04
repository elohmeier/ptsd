{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "2020-06-04";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "6ac6ee6f9a87e63136c6523208217633c4684a95";
    sha256 = "1d58haln5lcaq7vwxndnxcjv3ayv93rpa5kwwsxwj2m7fvsf5zgp";
  };

  cargoSha256 = "1g1k4fvpryr9fpbg6s3wfsr1z6ia8blsbysfdr6i50sbh796f2fz";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
