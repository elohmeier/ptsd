{ pkgs }:
pkgs.writeDashBin "nwlock" ''
  XY=$(${pkgs.xorg.xrandr}/bin/xrandr --current | grep '*' | uniq | head -n 1 | ${pkgs.gawk}/bin/awk '{print $1}')

  ${pkgs.imagemagick}/bin/convert ${<ci/os/Nerdworks_Hamburg_Logo_Web_Negativ_Weiss.png>} -background black -gravity center -extent $XY RGB:- | ${pkgs.i3lock}/bin/i3lock --color=000000 --image /dev/stdin --raw "$XY:rgb"

''
