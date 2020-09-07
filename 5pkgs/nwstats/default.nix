{ buildPythonPackage, fetchgit, requests, flask }:

buildPythonPackage rec {
  pname = "nwstats";
  version = "1.0.1";

  src = fetchgit {
    url = "https://git.nerdworks.de/nerdworks/${pname}.git";
    rev = "refs/tags/${version}";
    sha256 = "0p5wv8zl669kgcc1smzfnnhl4wg74b3yp1dgh5nbpfz8a023crbr";
  };

  doCheck = false;

  propagatedBuildInputs = [
    requests
    flask
  ];
}
