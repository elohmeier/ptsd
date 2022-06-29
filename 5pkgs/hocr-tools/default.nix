{ buildPythonPackage, fetchFromGitHub, pillow, lxml, reportlab, python-bidi }:

buildPythonPackage {
  pname = "hocr-tools";
  version = "2022-03-12";
  src = fetchFromGitHub {
    owner = "ocropus";
    repo = "hocr-tools";
    rev = "fe9c90aa4cc803191416160d6d35e2a302b59013";
    sha256 = "sha256-o8RRKZAw+vf2nDKJqvV9ti34ZKwCLLUwGWNceeeidyM=";
  };
  doCheck = false;
  propagatedBuildInputs = [ pillow lxml reportlab python-bidi ];
}
