{ buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "pptree";
  version = "3.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-TdC6L1gADL0p1opbZLrCm8taZjZC95QEh3wAWWaKafY=";
  };

  doCheck = false;

  propagatedBuildInputs = [ ];
}
