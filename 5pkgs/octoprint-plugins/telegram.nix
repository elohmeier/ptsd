{ buildPythonPackage, fetchFromGitHub, octoprint, pillow }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-Telegram";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "fabianonline";
    repo = "OctoPrint-Telegram";
    rev = version;
    sha256 = "1v12m1bxd6l7wd3nr1gjqfh0pzllr8m8gn74s9ni3g0zf0a0x21m";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow ];
}
