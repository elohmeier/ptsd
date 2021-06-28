{ buildPythonPackage, fetchPypi, pytestCheckHook, setuptools_scm }:

buildPythonPackage rec {
  pname = "orgparse";
  version = "0.2.4";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-W2wwEs9FmwIB1C9Y3QLalr7u0JE/ZAgPFQsmZmVbTXQ=";
  };
  checkInputs = [ pytestCheckHook ];
  buildInputs = [ setuptools_scm ];
  doCheck = false;
}
 
