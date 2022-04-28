{ stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "kanboard-plugin-google-auth";
  version = "1.0.8";
  src = fetchFromGitHub {
    owner = "kanboard";
    repo = "plugin-google-auth";
    rev = "v${version}";
    sha256 = "sha256-VrYomAPAJboH2uF4W6khKUaLxIq9rXwUCDARyXCKheU=";
  };
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/plugins
    cp -r . $out/plugins/GoogleAuth
  '';
}
