{ stdenv, requireFile, makeWrapper, unzip, zlib, fontconfig, freetype, openssl_1_0_2, xorg, glib, libGL, alsaLib, libpulseaudio, boost, qt5, makeDesktopItem, autoPatchelfHook, libxkbcommon, dbus, coreutils }:

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
in
stdenv.mkDerivation rec {
  pname = "velocidrone";
  version = "1.15.0";

  src = requireFile {
    name = "velocidrone-debian-launcher.zip";
    sha256 = "173fzs21czz07fijy36ybhsjiz73qw24zxd6ahm9v2clj4mfvgrv";
    message = ''
      nix-prefetch-url file://\$PWD/velocidrone-debian-launcher.zip
    '';
  };
  unpackPhase = "unzip $src";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = deps;

  installPhase = ''
    runHook preInstall

    libdir=$out/lib/velocidrone
    mkdir -p $libdir

    # add deps not detected by autoPatchelfHook (found them with strace)
    ln -s ${dbus.lib}/lib/libdbus-1.so $libdir/

    mkdir -p $out/velocidrone
    mkdir -p $out/bin

    mv Launcher $out/velocidrone/
    mv launcher.dat $out/velocidrone/

    librarypath="${stdenv.lib.makeLibraryPath deps}:$libdir"
    #wrapProgram $out/velocidrone/Launcher \
    #  --prefix LD_LIBRARY_PATH : "$librarypath" \
    #  --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb"

    substitute ${./velocidrone.sh} $out/bin/velocidrone \
      --subst-var out \
      --subst-var-by coreutils ${coreutils} \
      --subst-var-by libraryPath "$librarypath" \
      --subst-var-by xkbRoot "${xorg.xkeyboardconfig}/share/X11/xkb"
    chmod 0755 $out/bin/velocidrone

    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications

    runHook postInstall
  '';
}
