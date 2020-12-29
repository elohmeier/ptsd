{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "docker-machine-driver-hetzner";
  version = "3.1.1";

  src = fetchFromGitHub {
    rev = version;
    owner = "JonasProgrammer";
    repo = pname;
    sha256 = "0mlvq43bv9a0gfl8yj6izi31gc31yfn9nabr3sgvw8yq6lm5q025";
  };
  vendorSha256 = "0hvcsf0qqry20ks398355s7km0gzvzz3nr0nf2svzp7s8raz17gq";
}
