{ fishPlugins, fetchFromGitHub }:

fishPlugins.buildFishPlugin {
  pname = "hydro";
  version = "2021-10-31";
  src = fetchFromGitHub {
    owner = "jorgebucaran";
    repo = "hydro";
    rev = "cf7b19842f03bc4df27f9281badfc2828c02b56a";
    sha256 = "sha256-d2ioK4smwYd49WP4Esd2jRaS82NzVFzi/Ljhy+QbFPc=";
  };

}
