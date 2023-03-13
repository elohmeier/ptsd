{ buildPythonPackage
, fetchPypi
, lib
, numpy
, hdbscan
, umap-learn
, pandas
, scikit-learn
, tqdm
, sentence-transformers
, plotly
, pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "bertopic";
  version = "0.14.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Ku0Lrj0XEofj1SJGCiyAv6nyb6+m8urevR1Fj0KsNGE=";
  };

  doCheck = false;

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRelaxDeps = [ "hdbscan" ];

  propagatedBuildInputs = [
    numpy
    hdbscan
    umap-learn
    pandas
    scikit-learn
    tqdm
    sentence-transformers
    plotly
  ];
}
