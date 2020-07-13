# copied from nixpkgs to use it in 20.03, can be removed in 20.09
{ stdenv, buildGoModule, fetchFromGitHub, go-bindata, nixosTests }:

buildGoModule rec {
  pname = "traefik";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "containous";
    repo = "traefik";
    rev = "v${version}";
    sha256 = "0w8jc4qj5c6sngdxrxl9bqda0vvplqf0d3xn175p3dwmw7mc6mdz";
  };

  vendorSha256 = "0kz7y64k07vlybzfjg6709fdy7krqlv1gkk01nvhs84sk8bnrcvn";
  subPackages = [ "cmd/traefik" ];

  nativeBuildInputs = [ go-bindata ];

  passthru.tests = { inherit (nixosTests) traefik; };

  preBuild = ''
    go generate
    CODENAME=$(awk -F "=" '/CODENAME=/ { print $2}' script/binary)
    makeFlagsArray+=("-ldflags=\
      -X github.com/containous/traefik/version.Version=${version} \
      -X github.com/containous/traefik/version.Codename=$CODENAME")
  '';

  meta = with stdenv.lib; {
    homepage = "https://traefik.io";
    description = "A modern reverse proxy";
    license = licenses.mit;
    maintainers = with maintainers; [ vdemeester ];
  };
}
