{ lib
, stdenv
, fetchFromGitHub
, imlib2
, pkg-config
, xlibsWrapper
, libheif
}:

let
  version = "0.1.1";
in
stdenv.mkDerivation {
  pname = "imlib2-heic";
  inherit version;

  src = fetchFromGitHub {
    owner = "vi";
    repo = "imlib2-heic";
    rev = "v${version}";
    sha256 = "sha256-idNn4748TQIVl8klXhNgp2v29mKj6syt9LHM1JqAi4k=";
  };

  buildInputs = [
    imlib2
    xlibsWrapper
    libheif
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  installFlags = [ "DESTDIR=$(out)" "LOADERDIR=/imlib2/loaders" ];

  meta = with lib; {
    description = "HEIC/HEIF decoder for imlib2";
    homepage = "https://github.com/vi/imlib2-heic";
    license = licenses.bsd3;
    maintainers = with maintainers; [ elohmeier ];
  };
}
