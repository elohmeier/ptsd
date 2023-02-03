{ buildPythonPackage, fetchFromGitHub, sqlalchemy, inflect }:

buildPythonPackage rec {
  pname = "sqlacodegen";
  version = "2022-08-15";

  src = fetchFromGitHub {
    owner = "agronholm";
    repo = "sqlacodegen";
    rev = "352e5187cb2ece9097da412f3df0dd659ba26abb";
    sha256 = "sha256-CVNxPif7VSYel6t+bbwO5aeJO0dD8JbT9I/Swo8OpRc=";
  };

  format = "pyproject";

  doCheck = false;

  propagatedBuildInputs = [ sqlalchemy inflect ];
}
