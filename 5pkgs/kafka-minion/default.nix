{ buildGoModule, fetchFromGitHub, stdenv }:

buildGoModule rec {
  pname = "kafka-minion";
  version = "1.0.0";
  goPackagePath = "github.com/cloudworkz/kafka-minion";

  vendorSha256 = "0a11p2h2f1qi2b2df62vjd1s0gvx10ma752ipyy64zdsba8qh75l";

  src = fetchFromGitHub {
    owner = "cloudworkz";
    repo = "kafka-minion";
    rev = "v${version}";
    sha256 = "14v8396prn4l6jvg8dmay8vq40jl99s2m17cqc4f083y2sblp8hh";
  };
}
