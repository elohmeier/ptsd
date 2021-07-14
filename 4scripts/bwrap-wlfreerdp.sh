#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bubblewrap -p freerdp

bwrap \
    --ro-bind /nix/store /nix/store \
    --tmpfs /run \
    --ro-bind /run/opengl-driver /run/opengl-driver \
    --ro-bind /run/current-system/sw/bin /run/current-system/sw/bin \
    --tmpfs /tmp \
    --proc /proc \
    --ro-bind /run/user/"$(id -u)"/$WAYLAND_DISPLAY /run/user/"$(id -u)"/$WAYLAND_DISPLAY \
    --dev /dev \
    --dev-bind /dev/dri /dev/dri \
    --ro-bind /sys/dev/char /sys/dev/char \
    --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00 \
    --bind ~/.config/freerdp ~/.config/freerdp \
    --unshare-all \
    --share-net \
    --hostname RESTRICTED \
    --setenv PATH /run/current-system/sw/bin \
    --die-with-parent \
    --new-session \
    $(readlink $(which wlfreerdp)) $@
