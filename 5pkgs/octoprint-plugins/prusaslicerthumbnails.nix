{ buildPythonPackage, fetchFromGitHub, octoprint, pillow }:

buildPythonPackage rec {
  pname = "OctoPrintPlugin-PrusaSlicerThumbnails";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jneilliii";
    repo = "OctoPrint-PrusaSlicerThumbnails";
    rev = version;
    sha256 = "sha256-/ySheTcbKVLxtqpx+ixSudsnowVNtWv1XbaVrv1j6rI=";
  };

  doCheck = false;

  propagatedBuildInputs = [ octoprint pillow ];
}
