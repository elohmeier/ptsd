{ buildPythonApplication, fetchgit, lxml, requests, vobject }:

buildPythonApplication rec {
  pname = "davphonebook";
  version = "0.0.1";

  src = fetchgit {
    url = "https://git.nerdworks.de/nerdworks/${pname}.git";
    rev = "refs/tags/${version}";
    sha256 = "0zlj63bkq753rbzl1w0lh1dh4m5v41hzr4j8hjvwm2n4n7jsvsh1";
  };

  propagatedBuildInputs = [
    lxml
    requests
    vobject
  ];
}
