{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  anthropic,
  llm,
  pytest,
  pytest-recording,
}:

buildPythonPackage rec {
  pname = "llm-claude-3";
  version = "0.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-claude-3";
    rev = version;
    hash = "sha256-5qF5BK319PNzB4XsLdYvtyq/SxBDdHJ9IoKWEnvNRp4=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [ anthropic ];

  checkInputs = [
    llm
    pytest
    pytest-recording
  ];

  pythonImportsCheck = [ "llm_claude_3" ];

  meta = with lib; {
    description = "LLM plugin for interacting with the Claude 3 family of models";
    homepage = "https://github.com/simonw/llm-claude-3";
    license = licenses.asl20;
    maintainers = with maintainers; [ ];
  };
}
