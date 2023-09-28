#!/usr/bin/env sh

bwrap \
  --ro-bind /nix/store /nix/store \
  --ro-bind /etc /etc \
  --dev /dev \
  --dev-bind /dev/dri /dev/dri \
  --proc /proc \
  --ro-bind /sys/dev/char /sys/dev/char \
  --ro-bind /sys/devices /sys/devices \
  --ro-bind /run/dbus /run/dbus \
  --ro-bind /run/opengl-driver /run/opengl-driver \
  --dir "/run/user/$(id -u)" \
  --ro-bind "/run/user/$(id -u)/wayland-1" "/run/user/$(id -u)/wayland-1" \
  --ro-bind "/run/user/$(id -u)/pipewire-0" "/run/user/$(id -u)/pipewire-0" \
  --ro-bind "/run/user/$(id -u)/pulse" "/run/user/$(id -u)/pulse" \
  --ro-bind "/run/user/$(id -u)/bus" "/run/user/$(id -u)/bus" \
  --tmpfs /tmp \
  --dir $HOME/.cache \
  --bind $HOME/.config/chromium $HOME/.config/chromium \
  --bind $HOME/Downloads $HOME/Downloads \
  --ro-bind $HOME/repos/password-store $HOME/repos/password-store \
  $(readlink $(which chromium)) --enable-features=UseOzonePlatform --ozone-platform=wayland $@
