{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-runner-exec";
  version = "1.0.0-beta.9";
  goPackagePath = "github.com/drone-runners/drone-runner-exec";

  modSha256 = "068319irh0vqvly4ylbfhw6ap7i09vgsjnd17s066f4q02v29swk";

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-exec";
    rev = "v${version}";
    sha256 = "1ay4vla54hrc3ranyc6whpqh0r1nynjg6x2ab1z1259ry9xzm4xs";
  };
}
