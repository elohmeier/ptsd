{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper }:

buildGoModule rec {
  name = "go-sqlcmd";
  vendorSha256 = "sha256-aQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "go-sqlcmd";
  };
}
