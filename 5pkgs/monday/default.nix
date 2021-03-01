{ buildPythonPackage, fetchPypi, requests }:

buildPythonPackage rec {
  pname = "monday";
  version = "1.2.0";
  src = fetchPypi {
    inherit pname version;
    sha256 = "15vf6irjkmqj3in2alwgzra43nj17csdf3450b3dr5syfd35cps8";
  };
  propagatedBuildInputs = [ requests ];
  doCheck = false;
}
