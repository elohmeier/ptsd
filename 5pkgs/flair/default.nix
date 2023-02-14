{ buildPythonPackage
, boto3
, bpemb
, conllu
, deprecated
, fetchFromGitHub
, ftfy
, gdown
, gensim
, huggingface-hub
, hyperopt
, langdetect
, lib
, lxml
, matplotlib
, more-itertools
, pptree
, python-dateutil
, python3Packages
, pythonRelaxDepsHook
, regex
, scikit-learn
, segtok
, sentencepiece
, sqlitedict
, tabulate
, torch
, tqdm
, transformers
}:

buildPythonPackage rec {
  pname = "flair";
  version = "0.11.3";

  src = fetchFromGitHub {
    owner = "flairNLP";
    repo = "flair";
    rev = "v${version}";
    hash = "sha256-O3vjUVeEPJZxRp0+9uiOrXcN5qA66HrLjIUYMhMLlOQ=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    # janome
    # mpld3
    # pytorch_revgrad
    # wikipedia-api
    boto3
    bpemb
    conllu
    deprecated
    ftfy
    gdown
    gensim
    huggingface-hub
    hyperopt
    langdetect
    lxml
    matplotlib
    more-itertools
    pptree
    python-dateutil
    regex
    scikit-learn
    segtok
    sentencepiece
    sqlitedict
    tabulate
    torch
    tqdm
    transformers
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  pythonRemoveDeps = [ "mpld3" "janome" "pytorch_revgrad" "wikipedia-api" "konoha" ];
  pythonRelaxDeps = [ "gdown" "sentencepiece" ];

  pythonImportsCheck = [ "flair.data" "flair.models" ];
}
