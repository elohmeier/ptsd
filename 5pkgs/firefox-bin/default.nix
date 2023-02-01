{ fetchurl
, firefox-unwrapped
, lib
, makeWrapper
, policies ? { }
, stdenv
, undmg
, writeText
}:

let
  policiesFile = writeText "policies.json" (builtins.toJSON { inherit policies; });
  hashes = {
    "108.0.2" = "sha256-DL+xmsJdcsqgSBccs6b5NsyER/t+pFGI2+wCkYTlMFI=";
    "109.0" = "sha256-1xLHcxBMqMbA15cPiFxvD2L8MxJoUpkffdsR47CyFc8=";
    "109.0.1" = "sha256-TWnxZ1gk/zF3ENTq24yodVc8KWkiR/OY4jvHpNMRWbo=";
  };
in
stdenv.mkDerivation rec {
  pname = "firefox-bin";
  version = firefox-unwrapped.version;

  src = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox%20${version}.dmg";
    sha256 = if builtins.hasAttr version hashes then hashes.${version} else lib.fakeSha256;
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
