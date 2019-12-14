{ pkgs }:
pkgs.writeDashBin "caffeine" ''
  ${pkgs.killall}/bin/killall xautolock
  ${pkgs.xorg.xset}/bin/xset s off -dpms
  echo "enjoy... ☕"
''
