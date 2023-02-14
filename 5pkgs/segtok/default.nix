{ buildPythonPackage, fetchPypi, regex }:

buildPythonPackage rec {
  pname = "segtok";
  version = "1.5.11";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-irLdRCRby/7CW1ddxGGEc7vfKvjCZJaYzVo3D0Lz2yM=";
  };

  doCheck = false;

  propagatedBuildInputs = [ regex ];
}
