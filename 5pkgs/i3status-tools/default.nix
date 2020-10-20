{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  name = "i3status-tools";
  goPackagePath = "git.nerdworks.de/nerdworks/ptsd/5pkgs/${name}";
  vendorSha256 = "14a5za8md7j0fqccxa9cyrqr3mzhza28ipshnfi15rcdq0qvj3ar";
  src = ./.;
}
