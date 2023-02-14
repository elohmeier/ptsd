{ buildPythonPackage, fetchPypi, gensim, numpy, requests, sentencepiece, tqdm }:

buildPythonPackage rec {
  pname = "bpemb";
  version = "0.3.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-xNMwwAv0zjanJzXRbIJfgDIIcbppjB6ccFo8gbS5wTM=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    gensim
    numpy
    requests
    sentencepiece
    tqdm
  ];
}
