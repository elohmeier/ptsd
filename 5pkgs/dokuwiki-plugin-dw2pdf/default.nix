{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dokuwiki-plugin-dw2pdf";
  version = "2020-05-11";
  src = fetchFromGitHub {
    owner = "splitbrain";
    repo = pname;
    rev = "${version}";
    sha256 = "1pkn76ncra7ymdy58dk48415fqm29f2il809qbcp9cakclsv07rq";
  };
  installPhase = ''
    mkdir -p $out/share/dokuwiki/lib/plugins/${pname}
    cp -r * $out/share/dokuwiki/lib/plugins/${pname}
  '';
}
