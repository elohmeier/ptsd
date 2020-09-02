{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "todoist-i3status";
  version = "dev";
  goPackagePath = "github.com/elohmeier/${pname}";
  modSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
  src = ./.;
}
