{ buildPythonApplication, orgparse, pytestCheckHook, pdfminer }:
buildPythonApplication {
  name = "nobbofin";
  src = ./.;
  propagatedBuildInputs = [ orgparse pdfminer ];
  checkInputs = [ pytestCheckHook ];
}
