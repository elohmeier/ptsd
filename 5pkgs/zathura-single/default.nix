{ pkgs }:
pkgs.writeDashBin "zathura-single" ''
  ${pkgs.killall}/bin/killall zathura 2>/dev/null
  ${pkgs.zathura}/bin/zathura "$*"
''
