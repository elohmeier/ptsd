{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "todoist-i3status";
  version = "dev";
  goPackagePath = "github.com/elohmeier/${pname}";
  modSha256 = "19xaam10080gfqysxh88960d04zsriij1sccf31akql49zmbbliz";
  src = ./.;
}
