{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "conllu";
  version = "4.5.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-fFgcDRL83VRsv2kFAGPDcxLeKN0wSMPxROxbhR5xiRw=";
  };

  doCheck = false;

  propagatedBuildInputs = [ ];
}
