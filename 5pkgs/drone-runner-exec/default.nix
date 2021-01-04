{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-runner-exec";
  version = "1.0.0-beta.9";

  vendorSha256 = "1k16xg17my0zqc4w03v9y3v4780pg9mnkvaibw3191aimi02x5na";

  src = fetchFromGitHub {
    owner = "drone-runners";
    repo = "drone-runner-exec";
    rev = "v${version}";
    sha256 = "1ay4vla54hrc3ranyc6whpqh0r1nynjg6x2ab1z1259ry9xzm4xs";
  };
}
