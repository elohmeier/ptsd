{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "pagebreak";
  src = fetchFromGitHub {
    owner = "mgroat"; # use fork containing unmerged compat bugfix
    repo = "dokuwiki-plugin-pagebreak";
    rev = "a9cfae702549bb01f6f0039f103be6f25c74a565";
    sha256 = "1jq5x50pxdwk18pjbqx37yh0shkk1rb34g486r5sgwa5ml1g6f5m";
  };
  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';
}
