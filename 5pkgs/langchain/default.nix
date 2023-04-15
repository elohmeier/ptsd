{ buildPythonPackage
, aiohttp
, chromadb
, dataclasses-json
, fetchPypi
, numpy
, pydantic
, pyyaml
, requests
, sqlalchemy
, tenacity
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "langchain";
  version = "0.0.129";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Qf/5BNyhUNbj9il5s46xvHVFIQw864QRNvDaMd34GdY=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    aiohttp
    chromadb
    dataclasses-json
    numpy
    pydantic
    pyyaml
    requests
    sqlalchemy
    tenacity
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = true;
}
