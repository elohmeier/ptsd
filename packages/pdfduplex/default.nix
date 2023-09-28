{ writers, pdftk, openjdk17 }:
let
  mypdftk = pdftk.override { jre = openjdk17; };
in
writers.writeDashBin "pdfduplex" ''
  A="''${1?must provide file A}"
  B="''${2?must provide file B}"

  A_fn=$(basename -- "$A")
  B_fn=$(basename -- "$B")

  DUP_fn="''${A_fn%.*}_''${B_fn}"

  ${mypdftk}/bin/pdftk A="$A" B="$B" shuffle A Bend-1 output "$DUP_fn"
''
