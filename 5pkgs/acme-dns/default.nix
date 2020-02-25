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

  modSha256 = "1ivvzc2m8z7rqy31ljjjzlv5inzfjq23r55gwjk1f6w7i0n8qy9g";
  goPackagePath = "github.com/joohoi/acme-dns";
}
