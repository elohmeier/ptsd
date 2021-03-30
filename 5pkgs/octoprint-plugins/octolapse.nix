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
    sha256 = "sha256-ZL/nkI3DS7HSVPEEgTIgweZiJj0GSpQCo3epvM4DAo8=";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow frb awesome-slugify ];
}
