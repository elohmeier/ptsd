{ stdenv, kitty }:

stdenv.mkDerivation {
  pname = "kitty-terminfo";
  version = kitty.version;
  src = kitty.src;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/terminfo
    cp "$src/terminfo/kitty.terminfo" $out/share/terminfo
  '';

}
