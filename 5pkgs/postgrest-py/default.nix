{ buildPythonPackage
, fetchPypi
, deprecation
, httpx
, pydantic
}:

buildPythonPackage rec {
  pname = "postgrest-py";
  version = "0.8.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-vOSzkau8oYySFVT/Hjg8Jbdys1aGVC4AQV5he5uioXo=";
  };

  propagatedBuildInputs = [ deprecation httpx pydantic ];
}
