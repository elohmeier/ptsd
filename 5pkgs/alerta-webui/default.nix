{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "alerta-webui";
  version = "7.4.1";

  src = fetchurl {
    url = "https://github.com/alerta/alerta-webui/releases/download/v${version}/alerta-webui.tar.gz";
    sha256 = "1a2bj6lbza6d7ablj7k6p0l1g53r8azl0yrxrcrmd5zmsgnv041h";
  };

  installPhase = ''
    cp -R . $out/
  '';
}
