{ buildPythonPackage, fetchFromGitHub, octoprint, pillow }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-Telegram";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "fabianonline";
    repo = "OctoPrint-Telegram";
    rev = version;
    sha256 = "1pvdzd36rnlds4cp5azhzv0cgcjcc6xsnank7nrcxfgzzvs4cllc";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow ];
}
