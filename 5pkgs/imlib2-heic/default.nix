{ stdenv, fetchFromGitHub, pkgconfig, imlib2, xlibsWrapper, libheif }:

stdenv.mkDerivation rec {
  pname = "imlib2-heic";
  version = "2018-12-14";

  src = fetchFromGitHub {
    owner = "vi";
    repo = "imlib2-heic";
    rev = "0f274dae338d942bf742a208a67ae1a2ffc94115";
    sha256 = "1jy6l89j1gdz7wc2nlr50l8kryby54if6lccn2jd1nnqc6x8i3l7";
  };

  buildInputs = [ imlib2 xlibsWrapper libheif ];

  nativeBuildInputs = [ pkgconfig ];

  installPhase = ''
    mkdir -p $out/lib/imlib2/loaders
    cp heic.so $out/lib/imlib2/loaders/
  '';

  meta = with stdenv.lib; {
    description = "HEIC/HEIF decoder for imlib2";
    homepage = "https://github.com/vi/imlib2-heic";
    maintainers = with maintainers; [ elohmeier ];
  };
}
