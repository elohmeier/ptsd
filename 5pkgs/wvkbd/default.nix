{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "wvkbd";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "jjsullivan5196";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-xkZTrkCV3wsA6rbs783LQ/DIkOSBqxzxMiC2CjjI4qM=";
  };


}
