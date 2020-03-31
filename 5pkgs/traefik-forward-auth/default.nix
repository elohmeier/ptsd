{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "traefik-forward-auth";
  version = "2.1.0";
  goPackagePath = "github.com/thomseddon/${pname}";

  modSha256 = "1g31lax99822v0ah1k4997dqq5fpy2v6kw74y7pan0sdhi9hcy6n";

  src = fetchFromGitHub {
    owner = "thomseddon";
    repo = pname;
    rev = "v${version}";
    sha256 = "1sxnbz0acvqxq7x52dv6rkxsym6majz5j1m0jsv5f1lib2wnsiz8";
  };
}
