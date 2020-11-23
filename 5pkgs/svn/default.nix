{ buildPythonPackage, fetchPypi, dateutil, nose, subversion }:

buildPythonPackage rec {
  pname = "svn";
  version = "1.0.1";
  src = fetchPypi {
    inherit pname version;
    sha256 = "0isjp7xa08nwb4a3dcm2c4iz0vrpsgiczc0091nxdh9whl3izy2m";
  };
  propagatedBuildInputs = [ dateutil ];
  checkInputs = [ nose ];
  postPatch = ''
    substituteInPlace svn/common.py \
      --replace "svn_filepath='svn'," "svn_filepath='${subversion}/bin/svn',"
  '';
}
