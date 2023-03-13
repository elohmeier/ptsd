{ buildPythonPackage
, fetchPypi
, lib
, numpy
, packaging
, psutil
, pyyaml
, torch
}:

buildPythonPackage rec {
  pname = "accelerate";
  version = "0.17.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-FvImuCGswe/obw4NXY8lZT3/VSNzXs4JkP7+p+t2B2o=";
  };

  propagatedBuildInputs = [
    numpy
    packaging
    psutil
    pyyaml
    torch
  ];
}
