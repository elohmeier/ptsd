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

  postInstall = ''
    mv $out/lib/obs/obs-plugins $out/lib/obs-plugins
    rm -rf $out/lib/obs

    mkdir -p $out/lib/obs-plugins/v4l2sink/bin/64bit
    mkdir -p $out/lib/obs-plugins/v4l2sink/data
    mv $out/lib/obs-plugins/v4l2sink.so $out/lib/obs-plugins/v4l2sink/bin/64bit/v4l2sink.so
    mv $out/lib/obs-plugins/v4l2sink/locale $out/lib/obs-plugins/v4l2sink/data/locale
  '';
}
