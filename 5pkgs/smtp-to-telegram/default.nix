{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "smtp_to_telegram";
  version = "2019-09-14";
  goPackagePath = "github.com/KostyaEsmukov/smtp_to_telegram";

  modSha256 = "14mkq8vrm4x15fw17yna1i2kzrjpxlg0gwvj3n7qdv56dc5glywg";

  src = fetchFromGitHub {
    owner = "KostyaEsmukov";
    repo = "smtp_to_telegram";
    rev = "308618c4a4b3ad1459a261b26414cb251325fd69";
    sha256 = "0l7mn63kgwp25m95l5yvyr0hzfqphhjd7jd43m9l845zr9rg13jf";
  };
}
