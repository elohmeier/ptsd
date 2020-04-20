{ buildPythonPackage, fetchPypi, black, nbconvert }:

buildPythonPackage rec {
  pname = "black_nbconvert";
  version = "0.2.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0wgk9hqfdcl84grzmkwqjllqhdhqzgf105kbqpkksnldb818lsfr";
  };
  propagatedBuildInputs = [ black nbconvert ];
}
