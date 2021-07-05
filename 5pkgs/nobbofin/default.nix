{ buildPythonApplication, orgparse, pytestCheckHook }:
buildPythonApplication {
  name = "nobbofin";
  src = ./.;
  propagatedBuildInputs = [ orgparse ];
  checkInputs = [ pytestCheckHook ];
}
