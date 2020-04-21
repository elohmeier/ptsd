{ buildPythonPackage, fetchPypi, requests }:
buildPythonPackage rec {
  pname = "pyfritzhome";
  version = "0.4.2";
  doCheck = false;
  propagatedBuildInputs = [ requests ];
  src = fetchPypi {
    inherit pname version;
    sha256 = "0ncyv8svw0fhs01ijjkb1gcinb3jpyjvv9xw1bhnf4ri7b27g6ww";
  };
}
