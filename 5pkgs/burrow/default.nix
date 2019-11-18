{ buildGoModule, fetchFromGitHub, stdenv }:

buildGoModule rec {
  pname = "Burrow";
  version = "2019-10-29";
  goPackagePath = "github.com/linkedin/Burrow";

  modSha256 = "0fvwykc9x85libwa9q8cbkh3926yzkf9gj0awq9q1jj47jvb975i";

  src = fetchFromGitHub {
    owner = "linkedin";
    repo = "Burrow";
    rev = "334be9125dcb3d0b5cddbee3f69cb956419d5a9e";
    sha256 = "155ini4kni0p1fqhbvl1iprj47j4avxs5cdyckhhpf8qf1mc12v1";
  };

  meta = with stdenv.lib; {
    license = licenses.asl20;
    description = "Burrow is a monitoring companion for Apache Kafka that provides consumer lag checking";
  };
}
