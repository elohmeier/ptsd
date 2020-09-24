{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "traefik-forward-auth";
  version = "2.2.0";
  goPackagePath = "github.com/thomseddon/${pname}";

  vendorSha256 = "1618j7lydmrjd3d8bfcbfadvadyc5g9pdpnp63xrxmgkizybvz64";

  src = fetchFromGitHub {
    owner = "thomseddon";
    repo = pname;
    rev = "v${version}";
    sha256 = "10may7zmih3fabkrm6nf5d5jb5g9q9k6i7a8563raxs5933qhipr";
  };
}
