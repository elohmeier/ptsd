{ writers, killall, xorg }:
writers.writeDashBin "caffeine" ''
  ${killall}/bin/killall xautolock
  ${xorg.xset}/bin/xset s off -dpms
  echo "enjoy... ☕"
''
