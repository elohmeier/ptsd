# copied from nixpkgs to use it in 20.03, can be removed in 20.09
{ stdenv, buildGoModule, fetchFromGitHub, go-bindata, nixosTests }:

buildGoModule rec {
  pname = "traefik";
  version = "2.2.10";

  src = fetchFromGitHub {
    owner = "containous";
    repo = "traefik";
    rev = "v${version}";
    sha256 = "013wd9kdrs8vq15cgrh79f0k2ndzyzaqhnfdg33xlqbfihydq7wv";
  };

  vendorSha256 = "06x2mcyp6c1jdf5wz51prhcn071d0580322lcv3x2bxk2grx08i2";
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
