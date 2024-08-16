{
  buildPythonPackage,
  fetchFromGitHub,
  octoprint,
}:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-PrusaLevelingGuide";
  version = "1.0.17";

  src = fetchFromGitHub {
    owner = "scottrini";
    repo = "OctoPrint-PrusaLevelingGuide";
    rev = version;
    sha256 = "sha256-UY1ADHQfcStXFIwOG3nmaqgVd8W02B8nUOpR8y1yxoI=";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint ];
}
