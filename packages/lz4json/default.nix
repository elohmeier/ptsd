{
  stdenv,
  fetchFromGitHub,
  lz4,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "lz4json";
  version = "2019-12-29";
  src = fetchFromGitHub {
    owner = "andikleen";
    repo = "lz4json";
    rev = "c44c51005c505de2636cc1e59cde764490de7632";
    sha256 = "sha256-rLjJ7qy7Tx0htW1VxrfCCqVbC6jNCr9H2vdDAfosxCA=";
  };
  buildInputs = [ lz4 ];
  nativeBuildInputs = [ pkg-config ];

  installPhase = ''
    mkdir -p $out/bin
    cp lz4jsoncat $out/bin/
  '';

  meta.description = "C decompress tool for mozilla lz4json format";
}
