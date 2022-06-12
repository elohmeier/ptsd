{ lib, stdenv, fetchurl, makeWrapper, undmg }:

stdenv.mkDerivation rec {
  pname = "logseq-bin";
  version = "0.7.3";

  src = fetchurl {
    url = "https://github.com/logseq/logseq/releases/download/${version}/Logseq-darwin-arm64-${version}.dmg";
    sha256 = "sha256-uk1VUX0W9HSZdD87NmKOGqlpid6EaWifrq0OyoTm+aA=";
  };

  nativeBuildInputs = [ makeWrapper undmg ];

  sourceRoot = "Logseq.app";

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/Applications/Logseq.app
    cp -R . $out/Applications/Logseq.app
    
    mkdir $out/bin
    makeWrapper $out/Applications/Logseq.app/Contents/MacOS/Logseq $out/bin/logseq

    runHook postInstall
  '';
}
