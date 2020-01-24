{ stdenv, requireFile, makeWrapper, unzip, zlib, fontconfig, freetype, openssl_1_0_2, xorg, glib, libGL, alsaLib, libpulseaudio }:

let
  deps = [
    alsaLib
    fontconfig
    freetype
    glib
    libGL
    libpulseaudio
    stdenv.cc.cc
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

  buildInputs = [ unzip makeWrapper ];

  dontBuild = true;

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    runHook preInstall

    libdir=$out/lib/velocidrone
    mkdir -p $libdir

    ln -s ${openssl_1_0_2.out}/lib/libssl.so $libdir/libssl.so.1.0.0
    ln -s ${openssl_1_0_2.out}/lib/libcrypto.so $libdir/libcrypto.so.1.0.0

    mkdir -p $out/velocidrone
    mkdir -p $out/bin

    mv Launcher $out/velocidrone/
    mv launcher.dat $out/velocidrone/

    patchelf --set-interpreter "${stdenv.glibc}/lib/ld-linux-x86-64.so.2" $out/velocidrone/Launcher

    librarypath="${stdenv.lib.makeLibraryPath deps}:$libdir"
    wrapProgram $out/velocidrone/Launcher \
      --prefix LD_LIBRARY_PATH : "$librarypath" \
      --set QT_XKB_CONFIG_ROOT "${xorg.xkeyboardconfig}/share/X11/xkb"

    ln -s $out/velocidrone/Launcher $out/bin/velocidrone

    runHook postInstall
  '';

}
