{ stdenv
, fetchFromGitHub
, cmake
, pkgconfig
, obs-studio
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "obs-v4l2sink";
  version = "2020-04-06";


  src = fetchFromGitHub {
    owner = "elohmeier";
    repo = pname;
    rev = "0c3d6753fb850393ceeb72fbf20050f9f9e74394";
    sha256 = "0xh7c5kks3hqabqbwkfckcv328mdfk1mfd7glmq7689idw29f26d";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [
    obs-studio
    qtbase
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-I${obs-studio.src}/UI/obs-frontend-api"
    "-DLIB_INSTALL_DIR=${placeholder "out"}/lib/obs"
    "-DSHARE_INSTALL_PREFIX=${placeholder "out"}/lib"
  ];
}
