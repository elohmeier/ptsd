{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "traefik-forward-auth";
  version = "2.1.0";
  goPackagePath = "github.com/thomseddon/${pname}";

  modSha256 = "1618j7lydmrjd3d8bfcbfadvadyc5g9pdpnp63xrxmgkizybvz64";

  src = fetchFromGitHub {
    owner = "thomseddon";
    repo = pname;
    rev = "v${version}";
    sha256 = "1sxnbz0acvqxq7x52dv6rkxsym6majz5j1m0jsv5f1lib2wnsiz8";
  };
}
