{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "smtp_to_telegram";
  version = "2019-09-14";
  goPackagePath = "github.com/KostyaEsmukov/smtp_to_telegram";

  vendorSha256 = "0q2v74vnclpywjr3pjr03panayqac60i6as87pcyfzmr7ani0wmb";

  src = fetchFromGitHub {
    owner = "KostyaEsmukov";
    repo = "smtp_to_telegram";
    rev = "308618c4a4b3ad1459a261b26414cb251325fd69";
    sha256 = "0l7mn63kgwp25m95l5yvyr0hzfqphhjd7jd43m9l845zr9rg13jf";
  };
}
