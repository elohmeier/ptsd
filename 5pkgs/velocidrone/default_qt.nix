{ qtbase, quazip, qmake, fetchFromGitHub, stdenv, requireFile, makeWrapper, unzip, zlib, fontconfig, freetype, openssl_1_0_2, xorg, glib, libGL, alsaLib, libpulseaudio, boost, qt5, makeDesktopItem, autoPatchelfHook, libxkbcommon, dbus, coreutils }:

let
  deps = [
    alsaLib
    boost
    fontconfig
    freetype
    glib
    libGL
    libpulseaudio
    openssl_1_0_2
    stdenv.cc.cc
    qt5.qtbase
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
    xorg.libxcb
    zlib
  ];

  desktopItem = makeDesktopItem {
    name = "Velocidrone";
    desktopName = "Velocidrone";
    exec = "velocidrone";
    icon = "velocidrone.png";
    terminal = "false";
    type = "Application";
    categories = "Game;";
    comment = "Fast paced FPV drone racing action with multiplayer and offline modes!";
  };

  src = requireFile
    {
      name = "velocidrone-debian-launcher.zip";
      sha256 = "173fzs21czz07fijy36ybhsjiz73qw24zxd6ahm9v2clj4mfvgrv";
      message = ''
        nix-prefetch-url file://\$PWD/velocidrone-debian-launcher.zip
      '';
    };

  launcherVersion = "1.5.1.0";
  launcherName = "patchkit-launcher-qt-${launcherVersion}";
  launcherSrc = fetchFromGitHub {
    owner = "patchkit-net";
    repo = "patchkit-launcher-qt";
    rev = "v${launcherVersion}";
    sha256 = "0gylmlwswfzhg2a24msgc57wawnr57wby6m1a0id3f5n2knq239h";
  };
in
stdenv.mkDerivation rec {
  pname = "velocidrone";
  version = "1.15.0";

  srcs = [
    src
    launcherSrc
  ];
  sourceRoot = launcherSrc.name;
  postUnpack = "mv launcher.dat ${sourceRoot}/";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    qmake
    quazip
  ];

  buildInputs = [ qtbase boost ];
  qmakeFlags = [ "PK_LAUNCHER_BOOST_LIBDIR=$out/lib" ];

  #buildInputs = deps;

  #  buildPhase = ''
  #    ls -la
  #
  #
  #  '';

  installPhase = ''
  '';

}
