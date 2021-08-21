{ buildPythonPackage, fetchPypi, pytz }:

buildPythonPackage rec {
  pname = "neo4j-driver";
  version = "4.3.4";
  propagatedBuildInputs = [ pytz ];
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-YF6Zr6yEkJ1lWH0yWaqI8wieiIOmiqlOKi5hz4StPV4=";
  };
  doCheck = false;
}
