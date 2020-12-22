{ python3Packages
, fetchFromGitHub
, makeWrapper
, flac
, sox
, faac
, vorbis-tools
, opusTools
, lame
, fdk-aac-encoder
, ffmpeg
}:

python3Packages.buildPythonApplication
rec {
  pname = "spotify-ripper";
  version = "2.16";

  src = fetchFromGitHub {
    owner = "scaronni";
    repo = pname;
    rev = version;
    sha256 = "01w6zn6aha47b99d4mhvsbklqv3l6qk1sssax2a42yk45rzxh4jz";
  };
  postPatch = ''
    substituteInPlace setup.py \
      --replace "os.makedirs(default_dir.encode(\"utf-8\"))" ""
  '';

  propagatedBuildInputs = with python3Packages;[
    pyspotify
    colorama
    mutagen
    requests
    schedule
    spotipy
  ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/spotify-ripper \
      --set PATH "$out/bin:${flac}/bin:${sox}/bin:${faac}/bin:${vorbis-tools}/bin:${opusTools}/bin:${lame}/bin:${fdk-aac-encoder}/bin:${ffmpeg}/bin"
  '';
}
