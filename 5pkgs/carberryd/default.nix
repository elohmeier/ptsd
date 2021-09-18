{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper }:

buildGoModule rec {
  name = "carberryd";
  vendorSha256 = "sha256-wOVhorpmcsE5fl071HxHYMzOOb7TS/0l5+GAxG9Bvq0=";
  src = ./.;
}
