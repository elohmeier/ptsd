{ buildPythonPackage, fetchFromGitHub, octoprint, numpy }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-BedLevelVisualizer";
  version = "0.1.13";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-BedLevelVisualizer";
    rev = version;
    sha256 = "0cn8zwcrxbdn7qqma4291x89bz4y3cmk6x52pa2awambzj565lfq";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint numpy ];
}
