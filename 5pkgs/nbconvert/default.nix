{ writers, python3 }:

let
  pyenv = python3.withPackages (
    pythonPackages: with pythonPackages; [
      jupyter
      nbconvert
    ]
  );
in
writers.writeDashBin "nbconvert" ''
  FILENAME="''${1?must provide filename}"
  ${pyenv}/bin/jupyter nbconvert --to script --stdout $FILENAME
''
