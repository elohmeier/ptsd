{ buildPythonPackage
, fetchPypi
, lib
, jsonschema
, oslash
, apply-defaults
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "jsonrpcserver";
  version = "4.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-DJ5blEViEThSHpEgFq45s7ra3SYHFA3LsMgGKTSrSFQ=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    jsonschema
    oslash
    apply-defaults
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = true;
}
