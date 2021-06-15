# nix-build -E 'with import <nixpkgs> {}; callPackage ./5pkgs/photoprism { libtensorflow1-bin = callPackage ./5pkgs/tensorflow1 {}; }'

{ lib, fetchFromGitHub, buildGoModule, libtensorflow1-bin }:

buildGoModule rec {
  pname = "photoprism";
  version = "210523-b1856b9d";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "sha256-zwx3kYIZXDuoy0hK54mHtwTzCpOWtxUoY24lpgC+cEU=";
  };

  vendorSha256 = "sha256-bQes6lR2CMM8Oimi2C/5qrP0MNW2GUfwUiKzY5QhP8M=";

  buildInputs = [
    libtensorflow1-bin
  ];

  doCheck = false;
}
