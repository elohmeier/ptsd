{ stdenv, ncurses5, cmake, libusb1 }:
stdenv.mkDerivation rec {
  name = "lguf-brightness";
  src = builtins.fetchGit {
    url = "https://github.com/elohmeier/lguf-brightness.git";
    rev = "4c5e89afbf4980baf785b31acb1bb39075f6ef23";
  };
  buildInputs = [ ncurses5 cmake libusb1 ];
  installPhase = ''
    install -D -m0755 lguf_brightness $out/bin/lguf_brightness
  '';
}
