{ writers, xorg, imagemagick, gawk, runCommand, xsecurelock, mpv, symlinkJoin }:
let
  myxsecurelock = xsecurelock.overrideAttrs (
    old: {
      buildInputs = old.buildInputs ++ [ mpv ];

      # nixpkgs' xsecurelock lacks mpv support, 
      # we also remove xscreensaver support here.
      configureFlags = [
        "--with-pam-service-name=login"
        "--with-mpv=${mpv}/bin/mpv"
      ];
    }
  );

  nwlock = writers.writeDashBin "nwlock" ''
    SRCIMAGE="''${1?must provide image path}"
    TMPIMG=`mktemp --suffix=.png`
    XY=$(${xorg.xrandr}/bin/xrandr --current | grep '*' | \
      uniq | head -n 1 | ${gawk}/bin/awk '{print $1}')  
    ${imagemagick}/bin/convert "$SRCIMAGE" \
      -background black -gravity center -extent $XY $TMPIMG

    XSECURELOCK_SAVER=saver_mpv \
    XSECURELOCK_IMAGE_DURATION_SECONDS=9999999999999 \
    XSECURELOCK_LIST_VIDEOS_COMMAND="echo $TMPIMG" \
    ${myxsecurelock}/bin/xsecurelock
    rm -f $TMPIMG
  '';
in
symlinkJoin {
  name = "xsecurelock-nwlock";
  paths = [ myxsecurelock nwlock ];
}
