{ buildPythonPackage, fetchFromGitHub, octoprint }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-PrusaSlicerThumbnails";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-PrusaSlicerThumbnails";
    rev = version;
    sha256 = "0p62psg9qyrhpcglvnwsxk29z2yryf9igwr2m38xq19gqm2dm2xm";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint ];
}
