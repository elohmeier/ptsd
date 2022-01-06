{ buildPythonPackage
, fetchPypi
, requests
, selenium
, tldextract
}:

buildPythonPackage rec {
  pname = "selenium-requests";
  version = "1.3.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-fQf5ttkHRlvRyfmYIFp62g0PmDHeku0Kcva3IY85FM0=";
  };

  propagatedBuildInputs = [
    requests
    selenium
    tldextract
  ];
}
