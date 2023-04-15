{ buildPythonPackage
, fetchPypi
, numpy
, pybind11
}:

buildPythonPackage rec {
  pname = "hnswlib";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-vEWWaOfkS7dFSyVrkMmMWvdQZTkZ2akWmNr89BbPZMQ=";
  };

  # doCheck = false;

  propagatedBuildInputs = [ numpy pybind11 ];
}
