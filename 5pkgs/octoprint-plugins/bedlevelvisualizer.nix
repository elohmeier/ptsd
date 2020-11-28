{ buildPythonPackage, fetchFromGitHub, octoprint, numpy }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-BedLevelVisualizer";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-BedLevelVisualizer";
    rev = version;
    sha256 = "1j7xs4laidbnvz7090b5qyl1qxb4ddvmr0kv5a7nn3wdyjlvw16f";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint numpy ];
}
