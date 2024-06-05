#!/usr/bin/env bash

w="${1?provide width}"
h="${2?provide height}"

modeline=$(cvt "$w" "$h" 60 | sed -n 2p | cut -c 10-)
mode=$(perl -pe 's/(\"[\w\.]+\").*/$1/' <<<"$modeline")
if ! xrandr | grep -q "$mode"; then
  echo adding new mode "$mode"
  xrandr --newmode "$modeline"
  xrandr --addmode "Virtual-1" "$mode"
fi

xrandr --output "Virtual-1" --mode "$mode"
