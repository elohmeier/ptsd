{ writers, killall, zathura }:
writers.writeDashBin "zathura-single" ''
  ${killall}/bin/killall zathura 2>/dev/null
  ${zathura}/bin/zathura "$*"
''
