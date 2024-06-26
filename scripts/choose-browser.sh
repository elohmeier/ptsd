#!/usr/bin/env bash
#src: https://github.com/kaihendry/dotfiles/blob/master/bin/xdg-open

profile="$(
  cat <<-EOF | bemenu --list 10
		Firefox-Office
		Firefox-Privacy
		Firefox-Burp
		Chromium
		Firefox-bwrap-enno
	EOF
)"

case "$profile" in
"Firefox-Office")
  echo "Firefox-Office"
  firefox -P office "$@"
  ;;
"Firefox-Privacy")
  echo "Firefox-Privacy"
  firefox -P privacy "$@"
  ;;
"Firefox-Burp")
  echo "Firefox-Burp"
  firefox -P burp "$@"
  ;;
"Chromium")
  chromium "$@"
  ;;
"Firefox-bwrap-enno")
  bwrap \
    --ro-bind /nix/store /nix/store \
    --tmpfs /run \
    --ro-bind /etc/fonts /etc/fonts \
    --ro-bind /etc/machine-id /etc/machine-id \
    --ro-bind /etc/resolv.conf /etc/resolv.conf \
    --dir /run/user/"$(id -u)" \
    --ro-bind /run/current-system/sw/bin /run/current-system/sw/bin \
    --ro-bind /run/user/"$(id -u)"/pulse /run/user/"$(id -u)"/pulse \
    --ro-bind /run/user/"$(id -u)"/"$WAYLAND_DISPLAY" /run/user/"$(id -u)"/"$WAYLAND_DISPLAY" \
    --proc /proc \
    --bind ~/.mozilla ~/.mozilla \
    --bind ~/.cache/mozilla ~/.cache/mozilla \
    --bind ~/Downloads ~/Downloads \
    --unshare-all \
    --share-net \
    --hostname RESTRICTED \
    --setenv MOZ_ENABLE_WAYLAND 1 \
    --setenv PATH /run/current-system/sw/bin \
    --die-with-parent \
    --new-session \
    "$(readlink "$(which firefox)")" -P bwrap-enno "$@"

  ;;
esac
