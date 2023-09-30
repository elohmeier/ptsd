{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, ruby
, bundlerEnv
, python3
}:

let
  env = bundlerEnv {
    inherit ruby;
    name = "dradis-ce-bundler-env";
    # gemdir = ./.;
    gemdir = fetchFromGitHub {
      owner = "dradis";
      repo = "dradis-ce";
      rev = "v4.10.0";
      hash = "sha256-xO1j5sghbz41U5HiXhG5da1rZFpFuD0gnzY9+BMyJFE=";
    };
    gemset = ./gemset.nix;

  };
in
env
