{ buildPythonPackage
, duckdb
, fastapi
, fetchPypi
, hnswlib
, numpy
, pandas
, pydantic
, requests
, sentence-transformers
, uvicorn
, watchfiles
, uvloop
, websockets
, httptools
}:

buildPythonPackage rec {
  pname = "chromadb";
  version = "0.3.20";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-IGab2fRbx/C2oVnCoowANvTKw9h7g8njQtPqyb9yF7Q=";
  };
  format = "pyproject";

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "'clickhouse_connect >= 0.5.7'," "" \
      --replace "'posthog >= 2.4.0'" ""
  '';

  doCheck = false;

  propagatedBuildInputs = [
    duckdb
    fastapi
    hnswlib
    numpy
    pandas
    pydantic
    requests
    sentence-transformers
    uvicorn
    websockets
    uvloop
    watchfiles
    httptools
  ];
}
