{ buildPythonPackage
, fetchPypi
, pydantic
, sqlalchemy
, requests
, pyyaml
, numpy
}:

buildPythonPackage rec {
  pname = "langchain";
  version = "0.0.69";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-GRwZ4GjCUpXbV0EH4cblcM4m3gkC1cXTmwKOMwkvaGM=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    pydantic
    sqlalchemy
    requests
    pyyaml
    numpy
  ];
}
