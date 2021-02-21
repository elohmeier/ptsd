{ buildPythonPackage, fetchFromGitHub, octoprint, pillow, awesome-slugify }:
let
  frb = buildPythonPackage rec{
    pname = "file_read_backwards";
    version = "2.0.0";
    src = fetchFromGitHub {
      owner = "RobinNil";
      repo = pname;
      rev = "v${version}";
      sha256 = "14si3bkpwjbwncwrr2gj66yf35pz82chwxvfnnypdzkyv15sbcq6";
    };
    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "OctoPrintPlugin-Octolapse";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "FormerLurker";
    repo = "Octolapse";
    rev = "v${version}";
    sha256 = "1i4n7h1ny2m354p61mzsvl4j23dqkjdyiv0xzbqnxg5dbkqzinwi";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow frb awesome-slugify ];
}
