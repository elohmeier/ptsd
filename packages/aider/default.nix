{
  lib,
  python3,
  fetchFromGitHub,
  universal-ctags,
  portaudio,
  tree-sitter-grammars,
  writeText,
}:
let
  py3 = python3.override {
    packageOverrides = self: super: {
      grep-ast = self.buildPythonPackage rec {
        pname = "grep_ast";
        version = "0.3.2";
        src = super.fetchPypi {
          inherit pname version;
          hash = "sha256-1TvH0l3++v53ZD/sGJqzjjy9g51UbAcKlQ6+2tgu4WQ=";
        };
        propagatedBuildInputs = with self; [
          tree-sitter-languages
          pathspec
        ];
      };

      tree-sitter-languages = self.buildPythonPackage rec {
        pname = "tree-sitter-languages";
        version = "1.10.2";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "grantjenks";
          repo = "py-tree-sitter-languages";
          rev = "refs/tags/v${version}";
          hash = "sha256-AuPK15xtLiQx6N2OATVJFecsL8k3pOagrWu1GascbwM=";
        };

        nativeBuildInputs = with self; [
          cython
          setuptools
        ];

        propagatedBuildInputs = with self; [ tree-sitter ];

        pythonImportsCheck = [ "tree_sitter_languages" ];

        # see upstream https://github.com/grantjenks/py-tree-sitter-languages/blob/main/build.py
        preBuild =
          let
            grammar-sql = fetchFromGitHub {
              owner = "DerekStride";
              repo = "tree-sitter-sql";
              rev = "89fd00d0aff3bc9985ac37caf362ec4fd9b2ba1d"; # 2024-06-07
              hash = "sha256-QTKggsvVWhszlcYS/WOPkykUyTDgwV1yVJ7jADA/5SM=";
            };

            script = writeText "build.py" ''
              from tree_sitter import Language
              Language.build_library('tree_sitter_languages/languages.so', [
                '${tree-sitter-grammars.tree-sitter-bash.src}',
                '${tree-sitter-grammars.tree-sitter-c.src}',
                '${tree-sitter-grammars.tree-sitter-c-sharp.src}',
                '${tree-sitter-grammars.tree-sitter-commonlisp.src}',
                '${tree-sitter-grammars.tree-sitter-cpp.src}',
                '${tree-sitter-grammars.tree-sitter-css.src}',
                '${tree-sitter-grammars.tree-sitter-dockerfile.src}',
                '${tree-sitter-grammars.tree-sitter-dot.src}',
                '${tree-sitter-grammars.tree-sitter-elisp.src}',
                '${tree-sitter-grammars.tree-sitter-elixir.src}',
                '${tree-sitter-grammars.tree-sitter-elm.src}',
                '${tree-sitter-grammars.tree-sitter-embedded-template.src}',
                '${tree-sitter-grammars.tree-sitter-erlang.src}',
                '${tree-sitter-grammars.tree-sitter-fortran.src}',
                '${tree-sitter-grammars.tree-sitter-go.src}',
                '${tree-sitter-grammars.tree-sitter-gomod.src}',
                '${tree-sitter-grammars.tree-sitter-haskell.src}',
                '${tree-sitter-grammars.tree-sitter-hcl.src}',
                '${tree-sitter-grammars.tree-sitter-html.src}',
                '${tree-sitter-grammars.tree-sitter-java.src}',
                '${tree-sitter-grammars.tree-sitter-javascript.src}',
                '${tree-sitter-grammars.tree-sitter-jsdoc.src}',
                '${tree-sitter-grammars.tree-sitter-json.src}',
                '${tree-sitter-grammars.tree-sitter-julia.src}',
                '${tree-sitter-grammars.tree-sitter-kotlin.src}',
                '${tree-sitter-grammars.tree-sitter-lua.src}',
                '${tree-sitter-grammars.tree-sitter-make.src}',
                '${tree-sitter-grammars.tree-sitter-markdown.src}/tree-sitter-markdown',
                '${tree-sitter-grammars.tree-sitter-ocaml.src}/grammars/ocaml',
                '${tree-sitter-grammars.tree-sitter-perl.src}',
                '${tree-sitter-grammars.tree-sitter-php.src}/php',
                '${tree-sitter-grammars.tree-sitter-python.src}',
                '${tree-sitter-grammars.tree-sitter-ql.src}',
                '${tree-sitter-grammars.tree-sitter-r.src}',
                '${tree-sitter-grammars.tree-sitter-regex.src}',
                '${tree-sitter-grammars.tree-sitter-rst.src}',
                '${tree-sitter-grammars.tree-sitter-ruby.src}',
                '${tree-sitter-grammars.tree-sitter-rust.src}',
                '${tree-sitter-grammars.tree-sitter-scala.src}',
                '${grammar-sql}',
                '${tree-sitter-grammars.tree-sitter-toml.src}',
                '${tree-sitter-grammars.tree-sitter-tsq.src}',
                '${tree-sitter-grammars.tree-sitter-typescript.src}/typescript',
                '${tree-sitter-grammars.tree-sitter-typescript.src}/tsx',
                '${tree-sitter-grammars.tree-sitter-yaml.src}',
              ])
            '';
          in
          ''
            python3 ${script}
          '';

        meta = with lib; {
          description = "Module for all tree sitter languages";
          homepage = "https://github.com/grantjenks/py-tree-sitter-languages";
          license = licenses.asl20;
          maintainers = with maintainers; [ fab ];
        };
      };
    };
  };

  version = "0.48.1";
in
py3.pkgs.buildPythonApplication rec {
  pname = "aider";
  format = "setuptools";
  inherit version;

  src = fetchFromGitHub {
    owner = "paul-gauthier";
    repo = "aider";
    rev = "v${version}";
    hash = "sha256-o/AW1Gisq6azZmpL6B1taAFVZZRkWZywSNXc1p4abZs=";
  };

  postPatch = ''
    rm aider/queries/tree-sitter-javascript-tags.scm # broken

    substituteInPlace aider/repomap.py \
      --replace '"ctags"' '"${universal-ctags}/bin/ctags"'
  '';

  propagatedBuildInputs =
    with py3.pkgs;
    [
      aiohttp
      aiosignal
      async-timeout
      attrs
      backoff
      beautifulsoup4
      certifi
      charset-normalizer
      configargparse
      diff-match-patch
      diskcache
      frozenlist
      gitdb
      gitpython
      grep-ast
      idna
      importlib-resources
      jsonschema
      litellm
      markdown-it-py
      mdurl
      multidict
      networkx
      numpy
      openai
      packaging
      playwright
      prompt-toolkit
      pygments
      pypandoc
      python-dotenv
      pyyaml
      requests
      rich
      scipy
      smmap
      sounddevice
      soundfile
      streamlit
      tiktoken
      tqdm
      urllib3
      wcwidth
      yarl
    ]
    ++ [
      portaudio
      universal-ctags
    ];

  checkInputs = with py3.pkgs; [ zipp ];

  # Tests require a Git repository
  doCheck = false;

  pythonImportsCheck = [ "aider.main" ];

  meta = with lib; {
    changelog = "https://github.com/paul-gauthier/aider/raw/v${version}/HISTORY.md";
    description = "AI pair programming in your terminal";
    homepage = "https://github.com/paul-gauthier/aider";
    license = licenses.asl20;
  };
}
