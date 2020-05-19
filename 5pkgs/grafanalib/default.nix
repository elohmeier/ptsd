{ buildPythonPackage, fetchPypi, attrs }:

buildPythonPackage rec {
  pname = "grafanalib";
  version = "0.5.7";
  propagatedBuildInputs = [ attrs ];
  src = fetchPypi {
    inherit pname version;
    sha256 = "1v4s881kj71xxqb5a59mcb91sprw2hgmxk9dbrh41bza5w8ikk59";
  };
  postPatch = ''
    substituteInPlace setup.py \
      --replace "'attrs==19.2'" "'attrs>=19.2'"
  '';
}
