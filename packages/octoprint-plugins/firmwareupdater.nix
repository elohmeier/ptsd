{ buildPythonPackage, fetchFromGitHub, octoprint }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-FirmwareUpdater";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "OctoPrint";
    repo = "OctoPrint-FirmwareUpdater";
    rev = version;
    sha256 = "sha256-GMImcFNG5E56d799wQrlgrNev3++R2JtWfjj3emSXfY=";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint ];
}
