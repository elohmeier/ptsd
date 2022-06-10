{ lib, stdenv, fetchurl, makeWrapper, unzip }:

stdenv.mkDerivation rec {
  pname = "subler-bin";
  version = "1.7.4";

  src = fetchurl {
    url = "https://bitbucket.org/galad87/subler/downloads/Subler-${version}.zip";
    sha256 = "sha256-4zkz6aiPXq1HXeQ8iOWD128kZJvMCNHnHeNDseLHcWA=";
  };

  nativeBuildInputs = [ makeWrapper unzip ];

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/Applications/Subler.app
    cp -R . $out/Applications/Subler.app
    
    makeWrapper $out/Applications/Subler.app/Contents/MacOS/Subler $out/bin/subler

    runHook postInstall
  '';
}
