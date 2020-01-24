{ pkgs ? import <nixpkgs> {} }:

# you need to comment out the #LD... lines in patcher/run.sh to get this working.
(
  pkgs.buildFHSUserEnv {
    name = "velocidrone-env";
    targetPkgs = pkgs: with pkgs; [
      alsaLib
      boost
      dbus.lib
      fontconfig
      freetype
      glib
      libGL
      libpulseaudio
      openssl_1_0_2
      stdenv.cc.cc.lib
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
      xorg.xkeyboardconfig
      zlib
    ];
  }
).env
