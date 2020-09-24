{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "hcunit";
  version = "0.7.4";
  goPackagePath = "github.com/xchapter7x/${pname}";

  vendorSha256 = "1hn679p1ai965s2jxd3k04fcq47qhpwbkkrblh60kk2w3aamiwgm";

  src = fetchFromGitHub {
    owner = "xchapter7x";
    repo = pname;
    rev = "v${version}";
    sha256 = "14zawbgpknl3qbbcia5bv2nbjmr3kp2zx4hspkbagsc4nxci36n0";
  };
}
