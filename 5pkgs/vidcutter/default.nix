{ buildPythonApplication, fetchFromGitHub, mpv-unwrapped, pyqt5, pyopengl }:

buildPythonApplication rec {
  pname = "vidcutter";
  version = "6.0.5.1";
  src = fetchFromGitHub {
    owner = "ozmartian";
    repo = pname;
    rev = version;
    sha256 = "sha256-QqXkNPriH+ccJGayKnpyjYsIAHNhvfo3t2bzITdOMdY=";
  };
  buildInputs = [ mpv-unwrapped ];
  propagatedBuildInputs = [ pyqt5 pyopengl ];
}
