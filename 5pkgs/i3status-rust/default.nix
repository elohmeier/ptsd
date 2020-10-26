{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio }:

rustPlatform.buildRustPackage rec {
  pname = "i3status-rust";
  version = "2020-10-23";

  src = fetchFromGitHub {
    owner = "greshake";
    repo = pname;
    rev = "22bc2a6ad6d9c29ae6d3653046cf689079379940";
    sha256 = "1sk31lmijzx4ic53higa5ffms8chxj1rm04v0260wxgvq0x2xfgp";
  };

  cargoSha256 = "1qi1h7ywnlrc4pc90qw53bscsj04wnjkcnd2vij2w7hwcwv22ppg";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ dbus libpulseaudio ];

  # Currently no tests are implemented, so we avoid building the package twice
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Very resource-friendly and feature-rich replacement for i3status";
    homepage = "https://github.com/greshake/i3status-rust";
    license = licenses.gpl3;
    maintainers = with maintainers; [ backuitist globin ma27 ];
    platforms = platforms.linux;
  };
}
