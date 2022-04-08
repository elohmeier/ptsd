{ stdenv, fetchgit, gitMinimal, php }:

stdenv.mkDerivation {
  pname = "pinephone-keyboard";
  version = "2022-02-02";

  src = fetchgit {
    url = "https://megous.com/git/pinephone-keyboard";
    rev = "91163251e6a5857c348912a4823c77fc29965328";
    sha256 = "sha256-eL35j3ymWodiX7KEerN40y8yMM151u1j6dhmS3OqE3A=";
  };

  buildInputs = [ gitMinimal php ];
  buildPhase = "make tools";

  installPhase = ''
    mkdir -p $out/bin
    cp -r build/ppkb* $out/bin
  '';
}
