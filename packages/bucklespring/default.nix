{ stdenv, lib, fetchFromGitHub, openal, alure, libX11, libXtst, pkg-config, libinput, makeWrapper, useLibInput ? false }:

stdenv.mkDerivation rec {
  pname = "bucklespring";
  version = "2020-02-24";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = pname;
    rev = "a88992206edede53ab280a98651caebe10b66f59";
    sha256 = "14g26cv2fharbgcacw59ybxrw9vzxrwpq1vxpj5x42i79hixs2iq";
  };

  buildInputs = [ openal alure pkg-config ] ++ (if useLibInput then [ libinput ] else [ libX11 libXtst ]);

  makeFlags = lib.optionals useLibInput [ "libinput=1" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp buckle $out/bin/buckle

    wrapProgram $out/bin/buckle \
      --set BUCKLESPRING_WAV_DIR "$out/share/buckle/wav"

    mkdir -p $out/share/buckle/wav
    cp wav/*.wav $out/share/buckle/wav/
  '';

  meta = with lib; {
    homepage = "https://github.com/zevv/bucklespring";
    description = "Nostalgia bucklespring keyboard sound";
    license = licenses.gpl2;
  };
}
