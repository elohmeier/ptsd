{ fetchFromGitHub, stdenv, python3Packages, makeWrapper, pulseaudio }:

python3Packages.buildPythonApplication {
  pname = "pulseaudio-dlna";
  version = "2019-01-27";

  src = fetchFromGitHub {
    owner = "joecksma";
    repo = "pulseaudio-dlna";
    rev = "c87584ca34067d7eb92f1cec6deb4429aa1373fa";
    sha256 = "02wx4gisqhww07l72d0lnksd5008zdjn4f0lpjk1fzixmjlyvbqp";
  };

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    docopt
    requests
    setproctitle
    psutil
    chardet
    notify2
    netifaces
    pyroute2
    pygobject2
    lxml
    PyChromecast
    setuptools
  ];

  postPatch = ''
    # dbus-python is correctly passed in propagatedBuildInputs, but for some reason setup.py complains.
    # The wrapped terminator has the correct path added, so ignore this.
    substituteInPlace setup.py --replace '"dbus-python >= 1.0.0",' ""
  '';

  nativeBuildInputs = [ makeWrapper ];

  # wrap calls to pactl
  postFixup = ''
    wrapProgram $out/bin/pulseaudio-dlna \
      --prefix PATH : "${stdenv.lib.makeBinPath [ pulseaudio ]}"
  '';
}
