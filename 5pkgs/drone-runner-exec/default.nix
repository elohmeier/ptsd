{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-runner-exec";
  version = "1.0.0-beta.8";
  goPackagePath = "github.com/drone-runners/drone-runner-exec";

  modSha256 = "0xv4fjx2a7da9mcj6ylzaj7ya6clzhv598xwafzd7l3p813rxa7j";

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-exec";
    rev = "v${version}";
    sha256 = "1dw7iaib3hq69njm8lq9xr7sj29v99jxjpbqjf0g6p6cw512llrs";
  };
}
