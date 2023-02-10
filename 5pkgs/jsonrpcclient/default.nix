{ buildPythonPackage
, fetchPypi
, lib
, jsonschema
, apply-defaults
, pythonRelaxDepsHook
, click
, requests
}:

buildPythonPackage rec {
  pname = "jsonrpcclient";
  version = "3.3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Ly0hjeAP91Mvae/tLiUV0wyQ+HPly5G/AN6Zbft4L4o=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    apply-defaults
    click
    jsonschema
    requests
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = true;
}
