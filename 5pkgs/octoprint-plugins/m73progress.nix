{ buildPythonPackage, fetchFromGitHub, octoprint }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-M73Progress";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "cesarvandevelde";
    repo = "OctoPrint-M73Progress";
    rev = "v${version}";
    sha256 = "0bgmvddzr3yjbr6wv6hng9hsk3q46lsmipplf48bcaw6c608lq1d";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint ];
}
