{ buildPythonPackage, fetchFromGitHub, thespian, ijson }:

buildPythonPackage rec {
  pname = "esrally";
  version = "2.0.1";
  propagatedBuildInputs = [ thespian ijson ];

  src = fetchFromGitHub {
    owner = "elastic";
    repo = "rally";
    rev = version;
    sha256 = "1v6rw6gfag6hk8vvc72d4b7xyg0aqfyhd1qvx1chgd384mh41x8v";
  };

  # postPatch = ''
  #   substituteInPlace setup.py \
  #     --replace "'attrs==19.2'" "'attrs>=19.2'"
  # '';
}
