{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "dokuwiki-plugin-pagebreak";
  version = "2018-02-02";
  src = fetchFromGitHub {
    owner = "mgroat"; # use fork containing unmerged compat bugfix
    repo = pname;
    rev = "a9cfae702549bb01f6f0039f103be6f25c74a565";
    sha256 = "1jq5x50pxdwk18pjbqx37yh0shkk1rb34g486r5sgwa5ml1g6f5m";
  };
  installPhase = ''
    mkdir -p $out/share/dokuwiki/lib/plugins/pagebreak
    cp -r * $out/share/dokuwiki/lib/plugins/pagebreak
  '';
}
