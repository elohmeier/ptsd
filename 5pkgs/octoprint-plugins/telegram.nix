{ buildPythonPackage, fetchFromGitHub, octoprint, pillow }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-Telegram";
  #version = "1.5.2";
  version = "py3dev";

  src = fetchFromGitHub {
    #owner = "fabianonline";
    owner = "szobov";
    repo = "OctoPrint-Telegram";
    #rev = version;
    rev = "e82f72ed2c76bf151af339d64f05f62177baf92c";
    #sha256 = "1m1rlv5vi45fz8s4aqy3wpfkvkivsw4fl1i5sbwkx46dcvb4cv87";
    sha256 = "0pvdzd36rnlds4cp5azhzv0cgcjcc6xsnank7nrcxfgzzvs4cllc";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow ];
}
