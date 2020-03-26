{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-gitea-release";
  version = "2019-03-28";
  goPackagePath = "github.com/drone-plugins/${pname}";

  modSha256 = "09q51hziq34v3shfwpqc5m9arlw4fvkxzk97xaj7pz6d4323vc30";

  src = fetchFromGitHub {
    owner = "drone-plugins";
    repo = pname;
    rev = "b656d40539bc247822485f9142b2b24bec97f235";
    sha256 = "14n4ayfd5rlv8zra9z1gcx1ras04ihswywyp76wi4in4609399zf";
  };
}
