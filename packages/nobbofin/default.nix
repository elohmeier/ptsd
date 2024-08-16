{
  buildPythonPackage,
  orgparse,
  pytestCheckHook,
  pdfminer,
}:
buildPythonPackage {
  name = "nobbofin";
  src = ./.;
  propagatedBuildInputs = [
    orgparse
    pdfminer
  ];
  checkInputs = [ pytestCheckHook ];
}
