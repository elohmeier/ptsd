{ pkgs ? import <nixpkgs> { config.packageOverrides = import ../. pkgs; } }:

let
  pyEnv = pkgs.ptsdPy3.withPackages (pyPkgs: with pyPkgs; [
    presidio-analyzer
    presidio-anonymizer
    flask
    spacy_models.en_core_web_lg
    spacy_models.de_core_news_md
    whitenoise
  ]);
in
pkgs.mkShell {
  buildInputs = [
    pyEnv

  ];
}
