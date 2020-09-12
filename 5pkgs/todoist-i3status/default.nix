{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "todoist-i3status";
  version = "dev";
  goPackagePath = "github.com/elohmeier/${pname}";
  vendorSha256 = "0xm9h8jds59qf93fmg8q7m61ijm36lmhycpdxy9g9imlyldhmxji";
  src = ./.;
}
