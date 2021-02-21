{ buildPythonPackage, fetchFromGitHub, octoprint }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-PrusaLevelingGuide";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "scottrini";
    repo = "OctoPrint-PrusaLevelingGuide";
    rev = version;
    sha256 = "1qc9vcsq54m61jczhlrcbjq0sdx13jvbgd02csywcq9fkjhdr1ai";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint ];
}
