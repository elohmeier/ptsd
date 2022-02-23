{ stdenv }:

stdenv.mkDerivation {
  name = "motion-web";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    cp *.{html,js} $out/
  '';
}
