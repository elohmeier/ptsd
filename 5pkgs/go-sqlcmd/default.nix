{ stdenv, fetchFromGitHub, buildGoModule, makeWrapper }:

buildGoModule rec {
  pname = "go-sqlcmd";
  version = "0.8.0";
  vendorSha256 = "sha256-/2AtszI7AhG1mNbc5lVimRxKXn6l/MwEd5kRtC26MUw=";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "go-sqlcmd";
    rev = "v${version}";
    sha256 = "sha256-m/UVm2Sn83amWuyYbNlp+tzekYCq53n0Bly+CE3/U7U=";
  };
  doCheck = false;
}
