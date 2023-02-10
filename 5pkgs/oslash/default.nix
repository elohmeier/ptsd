{ buildPythonPackage, fetchPypi, lib, typing-extensions }:

buildPythonPackage rec {
  pname = "OSlash";
  version = "0.6.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-horrWKZW8u07c9ndar44eyC3T8lBPT6GU7YVsVv3KPM=";
  };

  doCheck = false;

  propagatedBuildInputs = [ typing-extensions ];
}
