{
  lib,
  python3,
  fetchFromGitHub,
  portaudio,
}:
let
  py3 = python3.override {
    packageOverrides = self: super: {

      jaraco-path = super.jaraco-path.overridePythonAttrs (oldAttrs: {
        postPatch = ''
          substituteInPlace setup.cfg \
            --replace-fail 'pyobjc; platform_system == "Darwin" and platform_python_implementation != "PyPy"' ""
        '';

        doCheck = false;
      });
    };
  };

  version = "0.49.1";
in
py3.pkgs.buildPythonApplication rec {
  pname = "aider";
  format = "setuptools";
  inherit version;

  src = fetchFromGitHub {
    owner = "paul-gauthier";
    repo = "aider";
    rev = "v${version}";
    hash = "sha256-E/Ih1IWwY4J1aPHOJJlNkj7ItQfWDUtfpnopIP2iAWg=";
  };

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
      pyperclip
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
    ++ [ portaudio ];

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
