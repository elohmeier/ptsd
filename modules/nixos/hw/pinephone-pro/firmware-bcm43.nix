{ stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "firmware-bcm43";
  version = "2021-10-27";
  src = fetchgit {
    url = "https://xff.cz/git/linux-firmware";
    rev = "6e8e591e17e207644dfe747e51026967bb1edab5";
    sha256 = "sha256-TaGwT0XvbxrfqEzUAdg18Yxr32oS+RffN+yzSXebtac=";
  };

  installPhase = ''
    mkdir -p $out/lib/firmware/brcm
    cp brcm/*43* $out/lib/firmware/brcm
  '';
}
