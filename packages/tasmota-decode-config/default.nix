{
  buildPythonPackage,
  configargparse,
  fetchFromGitHub,
  paho-mqtt,
  requests,
}:

buildPythonPackage rec {
  pname = "decode-config";
  version = "12.1.1";

  src = fetchFromGitHub {
    owner = "tasmota";
    repo = "decode-config";
    rev = "v${version}";
    sha256 = "sha256-UAIz9O1JNZ6ARbX7cgR8n6DSCEUM/ifet8OlZuuDcdg=";
  };

  doCheck = false;

  propagatedBuildInputs = [
    configargparse
    paho-mqtt
    requests
  ];
}
