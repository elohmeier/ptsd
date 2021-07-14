{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper }:

buildGoModule rec {
  name = "gowpcontactform";
  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
  src = ./.;
}
