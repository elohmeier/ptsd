{ buildPythonPackage
, edlib
, fetchPypi
, jsonrpcclient
, jsonrpcserver
, jupytext
, lib
, loguru
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "jupyter_ascending";
  version = "0.1.24";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-yeOvBA+GFPvhv/yyWLO3egV44ArnVlW3afAzwPolHNA=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    edlib
    jsonrpcclient
    jsonrpcserver
    jupytext
    loguru
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = true;
}
