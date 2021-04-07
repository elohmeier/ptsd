{ buildPythonPackage, fetchPypi, black, nbconvert, setuptools_scm }:

buildPythonPackage rec {
  pname = "black_nbconvert";
  version = "0.2.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0wgk9hqfdcl84grzmkwqjllqhdhqzgf105kbqpkksnldb818lsfr";
  };
  buildInputs = [ setuptools_scm ];
  propagatedBuildInputs = [ black nbconvert ];
}
 