{ buildPythonPackage
, fetchFromGitHub
, spacy
, regex
, tldextract
, pyyaml
, pydantic
, phonenumbers
}:

let
  version = "2.2.21";
  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "presidio";
    rev = version;
    sha256 = "sha256-DNC5g0FgbDOzq4HG7B/JVdEjUIerPBn3ukc/5/d281g=";
  };
in
buildPythonPackage {
  inherit version src;
  pname = "presidio_analyzer";
  sourceRoot = "source/presidio-analyzer";

  postPatch = ''
    substituteInPlace setup.py \
      --replace "spacy==3.0.6" "spacy" \
      --replace "regex==2020.11.13" "regex" \
      --replace "tldextract==3.1.0" "tldextract" \
      --replace "pyyaml==5.4.1" "pyyaml" \
      --replace "pydantic==1.7.4" "pydantic" \
      --replace "phonenumbers==8.12.24" "phonenumbers"
  '';

  propagatedBuildInputs = [
    spacy
    regex
    tldextract
    pyyaml
    pydantic
    phonenumbers
  ];

  doCheck = false; #TODO
}
