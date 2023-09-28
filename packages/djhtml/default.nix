{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "djhtml";
  version = "1.5.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-tUxKtu/689vofWFrowME8duiLwcSelY99BMKcazCkOo=";
  };

  doCheck = false;

  propagatedBuildInputs = [ ];
}
