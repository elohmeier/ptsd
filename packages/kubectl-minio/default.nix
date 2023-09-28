{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "kubectl-minio";
  version = "4.5.8";
  vendorSha256 = "sha256-E6B8y8jaNMpJtTs7mTJ9n5p15Wod9Lto/1xa1BhBJlQ=";
  src = fetchFromGitHub {
    owner = "minio";
    repo = "operator";
    rev = "v${version}";
    sha256 = "sha256-dp/ooUh5q5bwFoalqCQWf87QmWmLmOzBC8/70obUXmk=";
  };
  sourceRoot = "source/kubectl-minio";
  ldflags = [
    "-s"
    "-w"
    "-X github.com/minio/kubectl-minio/cmd.version=${version}"
  ];
}
