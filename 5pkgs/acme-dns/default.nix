{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "acme-dns";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "joohoi";
    repo = pname;
    rev = "v${version}";
    sha256 = "1v2k8kfws4a0hmi1almmdjd6rdihbr3zifji623wwnml00mjrplf";
  };

  vendorSha256 = "08y2v0na856wmc7mwjlnqqlbd22p7a7ichzqgcbl8zdzy6b7cbn8";
  goPackagePath = "github.com/joohoi/acme-dns";
}
