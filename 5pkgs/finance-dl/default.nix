{ buildPythonPackage
, fetchFromGitHub
, chromedriver
, beautifulsoup4
, ofxclient
, selenium
, ipython
, selenium-requests
, beancount
, atomicwrites
, jsonschema
, setuptools-scm
}:

buildPythonPackage rec {
  pname = "finance-dl";
  version = "2021-12-14";
  src = fetchFromGitHub {
    owner = "jbms";
    repo = pname;
    rev = "d3e28fa914b77fc2b6503d4dc366727dfa39d255";
    sha256 = "sha256-fW44B2yUimyEwHXdIggNMNL57kuknPW4scRntMQotC4=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'bs4'" "'beautifulsoup4'" \
      --replace "'mintapi>=1.31'," "" \
      --replace "'chromedriver-binary'," "" \
      --replace "'selenium-requests'," ""

    substituteInPlace finance_dl/chromedriver_wrapper.py \
      --replace "import chromedriver_binary" "" \
      --replace "os.getenv('ACTUAL_CHROMEDRIVER_PATH', 'chromedriver')" "'${chromedriver}/bin/chromedriver'"
  '';

  propagatedBuildInputs = [
    beautifulsoup4
    # mintapi
    ofxclient
    selenium
    ipython
    selenium-requests
    beancount
    atomicwrites
    jsonschema
    setuptools-scm
  ];
}
