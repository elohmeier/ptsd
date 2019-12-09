let
  nixpkgs-lib = import <nixpkgs/lib>;
  lib = with lib; nixpkgs-lib // builtins // {
    eq = x: y: x == y;

    # add custom functions here
  };
in
lib
