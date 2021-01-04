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

  vendorSha256 = "0ys87vm5c6h1nrwbwa620qmxdhccfvgjci27p9v4gllgrgnicscd";
}
