{ buildPythonPackage, fetchPypi, aiohttp, xmltodict, pytz }:

buildPythonPackage rec {
  pname = "PyMetno";
  version = "0.5.0";
  propagatedBuildInputs = [ aiohttp xmltodict pytz ];
  src = fetchPypi {
    inherit pname version;
    sha256 = "0j0rl81xdmdi13krdrmzyfk5shviq8czfs1xgr0100i0jm258cp5";
  };
}
