{ python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
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
}
