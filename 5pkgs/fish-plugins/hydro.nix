{ buildFishPlugin, fetchFromGitHub }:

buildFishPlugin {
pname = "hydro";
version = "2021-10-31";
  src = fetchFromGitHub {
    owner = "jorgebucaran";
    repo = "hydro";
    rev = "cf7b19842f03bc4df27f9281badfc2828c02b56a";
    sha256 = "1x1h65l8582p7h7w5986sc9vfd7b88a7hsi68dbikm090gz8nlxx";
  };

}
