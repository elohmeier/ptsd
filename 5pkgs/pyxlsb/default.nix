{ buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "pyxlsb";
  version = "1.0.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-KG8IpVcDM46sRw+n/s1quLRNyw7qij6z71A7oibklmo=";
  };
}
