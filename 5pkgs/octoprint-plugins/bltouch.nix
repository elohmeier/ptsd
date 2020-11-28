{ buildPythonPackage, fetchFromGitHub, octoprint, numpy }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-BLTouch";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-BLTouch";
    rev = version;
    sha256 = "0w1ahkd7hf4ljlzjgb9qfirx2inrf8gi07i3kk76dzxsdjm4j1vx";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint ];
}
