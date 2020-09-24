{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "drone-telegram";
  version = "1.3.7";

  vendorSha256 = "1r5vjsb9ncw4lnxg77k9mnsm907vrbcmsghgc4g9vr6r13agfrq2";

  # some tests require network access, therefore disabled
  # TODO: disable failing tests individually
  doCheck = false;

  src = fetchFromGitHub {
    owner = "appleboy";
    repo = pname;
    rev = "v${version}";
    sha256 = "1k2jj7fzb30qdz65l14ilds3nhxm8h9mxszp1ay40nrbqp05c9v4";
  };
}
