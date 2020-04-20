{ buildPythonPackage, fetchPypi, black, ipython }:

buildPythonPackage rec {
  pname = "nb_black";
  version = "1.0.7";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0aynnsqnmrvkc7awx7li1zvbwlgrz2hp7b3rdl56lpv78qx2x98w";
  };
  propagatedBuildInputs = [ black ipython ];
}
