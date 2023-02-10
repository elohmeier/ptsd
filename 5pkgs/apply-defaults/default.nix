{ buildPythonPackage, fetchPypi, lib }:

buildPythonPackage rec {
  pname = "apply_defaults";
  version = "0.1.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-N3PeNJG5TA/kQxDxqFiIOJzcceFUSzQ7zg0r1pkazqU=";
  };

  doCheck = false;

  propagatedBuildInputs = [ ];
}
