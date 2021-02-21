{ buildPythonPackage, fetchFromGitHub, octoprint, pillow }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-Telegram";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "fabianonline";
    repo = "OctoPrint-Telegram";
    rev = version;
    sha256 = "14d9f9a5m1prcikd7y26qks6c2ls6qq4b97amn24q5a8k5hbgl94";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow ];
}
