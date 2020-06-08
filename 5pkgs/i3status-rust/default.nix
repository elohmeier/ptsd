{ stdenv, rustPlatform, fetchFromGitHub, fetchpatch, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "v${version}";
    sha256 = "0d2xigm932x6pc9z24g5cg8xq2crd9n3wq1bwi96h35w799lagjg";
  };

  patches = [
    # fix forgotten Cargo.lock update in 0.14.0 release
    (
      fetchpatch {
        url = "https://github.com/greshake/i3status-rust/commit/7762a5c7ad668272fb8bb8409f12242094b032b8.patch";
        sha256 = "097f6w91cn53cj1g3bbdqm9jjib5fkb3id91jqvq88h43x14b8zb";
      }
    )
  ];

  cargoSha256 = "098d08likpnycfb32s83vp0bphxf27k1gfcc26721fc9c8ah0lah";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;
}
