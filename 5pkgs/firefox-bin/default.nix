{ lib, stdenv, fetchurl, makeWrapper, undmg, writeText, policies ? { } }:

let
  policiesFile = writeText "policies.json" (builtins.toJSON { policies = policies; });
in
stdenv.mkDerivation rec {
  pname = "firefox-bin";
  version = "101.0";

  src = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
    sha256 = "sha256-foB6oiQpL7qYZMoIodZLiF3HTIEjmcdE3fXsOgG8ZfA=";
  };

  nativeBuildInputs = [ makeWrapper undmg ];

  sourceRoot = "Firefox.app";

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/Applications/Firefox.app
    cp -R . $out/Applications/Firefox.app
    
    mkdir $out/bin
    makeWrapper $out/Applications/Firefox.app/Contents/MacOS/firefox $out/bin/firefox

    ${lib.optionalString (policies != {}) "mkdir $out/Applications/Firefox.app/Contents/Resources/distribution; cp ${policiesFile} $out/Applications/Firefox.app/Contents/Resources/distribution/policies.json"}

    runHook postInstall
  '';
}
