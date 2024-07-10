{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "edge-tts";
  version = "6.1.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rany2";
    repo = "edge-tts";
    rev = "dfd4cab849a988d9587684cf3f9f9536c92b8f4d";
    hash = "sha256-/ECNgsVtR2S5METj5ck7cM9jS9igiBH4GUxMvhWRINU=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.certifi
    python3.pkgs.aiohttp
  ];

  pythonImportsCheck = [ "edge_tts" ];

  meta = with lib; {
    description = "Use Microsoft Edge's online text-to-speech service from Python WITHOUT needing Microsoft Edge or Windows or an API key";
    homepage = "https://github.com/rany2/edge-tts";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "edge-tts";
  };
}
