{ buildPythonPackage
, fetchFromGitHub
, pycryptodome
}:

buildPythonPackage rec {
  pname = "presidio_anonymizer";
  version = "2.2.32";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "presidio";
    rev = version;
    sha256 = "sha256-W5RZegVos1oWKdxGnvPDn4Ek7SygsJ8e7yyNiY8kAZQ=";
  };
  sourceRoot = "source/presidio-anonymizer";

  propagatedBuildInputs = [
    pycryptodome
  ];
}
