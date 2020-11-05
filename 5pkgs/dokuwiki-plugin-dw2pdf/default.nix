{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "dw2pdf";
  src = fetchFromGitHub {
    owner = "splitbrain";
    repo = "dokuwiki-plugin-dw2pdf";
    rev = "2020-05-11";
    sha256 = "1pkn76ncra7ymdy58dk48415fqm29f2il809qbcp9cakclsv07rq";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
