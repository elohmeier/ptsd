{ stdenv, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "quotes-exporter";
  version = "2021-05-07";

  vendorSha256 = "sha256-ulRFPvKN8T7F8+bNbCabVICYV0uzCuMEgQZtnfXGCgg=";

  src = fetchFromGitHub {
    owner = "marcopaganini";
    repo = pname;
    rev = "a762636d93adffb781250256a2828f82532982bb";
    sha256 = "sha256-XjVS9QCraCA9tOmbRqerYJ71XMai9Ev37P6OULz0vdI=";
  };
}
