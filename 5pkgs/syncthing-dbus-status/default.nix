{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "syncthing-dbus-status";
  version = "dev";
  goPackagePath = "github.com/elohmeier/${pname}";
  vendorSha256 = "148wghrdyxjkqck8wwrb1lkfp71cbr9d2y8awa6siaflmplzdv77";
  src = ./.;
}
