{ stdenv, lib, fetchFromGitHub, jq, curl, makeWrapper }:

stdenv.mkDerivation {
  pname = "telegram.sh";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "fabianonline";
    repo = "telegram.sh";
    rev = "69f567428f8be6496eaaf6acbabca337f48954b6";
    sha256 = "18sd9y3ckwy69d5gy5zqp7d423f8fl9c1fcjv5h3wpkwc8c9sw9n";
  };

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp telegram "$out/bin/telegram"
    wrapProgram "$out/bin/telegram" --prefix PATH : ${lib.makeBinPath [ jq curl ]}
  '';
}
