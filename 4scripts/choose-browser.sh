#!/usr/bin/env bash
# src: https://github.com/kaihendry/dotfiles/blob/master/bin/xdg-open

profile="$(\
    cat <<- EOF | dmenu -i -l 10 -fn "SauceCodePro Nerd Font (TTF):pixelsize=26"
Firefox
Chromium
EOF
)"

case "$profile" in
    "Firefox")
    echo "Firefox"
    firefox "$@"
    ;;
    "Chromium")
    chromium "$@"
    ;;
esac
