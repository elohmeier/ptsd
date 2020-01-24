#!@bash@/bin/bash -e

VELOCIDRONEROOT=~/.velocidrone

# Add coreutils to PATH for mkdir, ln and cp used below
PATH=$PATH${PATH:+:}@coreutils@/bin

mkdir -p "$VELOCIDRONEROOT"
cp -f "@out@/velocidrone/Launcher" "$VELOCIDRONEROOT/Launcher"
cp -f "@out@/velocidrone/launcher.dat" "$VELOCIDRONEROOT/launcher.dat"

export LD_LIBRARY_PATH='@libraryPath@'
export QT_XKB_CONFIG_ROOT='@xkbRoot@'

$VELOCIDRONEROOT/Launcher "$@"
