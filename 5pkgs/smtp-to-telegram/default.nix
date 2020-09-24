{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "smtp_to_telegram";
  version = "2020-05-09";

  vendorSha256 = "1lfabrh5skaffqsx1zh5g5prd9i3s9w734994mwal7cn18hzdfxb";

  src = fetchFromGitHub {
    owner = "KostyaEsmukov";
    repo = pname;
    rev = "8092fc365b902d160d3e3de6ceb7ca67a17392d0";
    sha256 = "074xpxs4jkc9g9sl82jzi7sg9szccjv6b0yaqa8pcwl2hgc0l8kh";
  };
}
