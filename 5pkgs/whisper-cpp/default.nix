{ stdenv, fetchFromGitHub, fetchurl, Accelerate, SDL2 }:

let
  model-large = fetchurl {
    url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-large.bin";
    sha256 = "sha256-fZn0GhBSXQIGvdrdhnYBgfqSBDi2szI34xGP9sg7tT0=";
  };
  model-base = fetchurl {
    url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-base.bin";
    sha256 = "sha256-YO1bw90U7qhWST0zQ0m0BXgt3K8AKNS130CINF+6Lv4=";
  };
in
stdenv.mkDerivation {
  pname = "whisper-cpp";
  version = "2022-12-02";
  src = fetchFromGitHub {
    owner = "ggerganov";
    repo = "whisper.cpp";
    rev = "78d13257be8094a71b65af401d4753281af2205a";
    sha256 = "sha256-dPWHzqnwWxknO4JXlf00Dsv9rTTxLSYfP6JIMC4S9iA";
  };
  postPatch = ''
    substituteInPlace examples/main/main.cpp \
      --replace 'std::string language  = "en";' 'std::string language = "de";' \
      --replace 'std::string model     = "models/ggml-base.en.bin";' 'std::string model = "${model-large}";'

    substituteInPlace examples/stream/stream.cpp \
      --replace 'std::string language  = "en";' 'std::string language = "de";' \
      --replace 'std::string model     = "models/ggml-base.en.bin";' 'std::string model = "${model-base}";'
  '';
  buildInputs = [ Accelerate SDL2 ];
  buildPhase = ''
    make main
    make stream
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp main $out/bin/whisper
    cp stream $out/bin/whisper-stream
  '';
}
