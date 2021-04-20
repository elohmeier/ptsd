{ runCommand, imagemagick, fetchgit, width ? 4096, height ? 2304 }:

runCommand "nerdworks-artwork"
{
  buildInputs = [ imagemagick ];
} ''
  mkdir -p "$out/scaled"

  convert ${./wallpaper-n3-4096.png} -resize \
    ${toString width}x${toString height}^ \
    "$out/scaled/wallpaper-n3.png"

  convert ${./wallpaper-fraam-2021-4096.png} -resize \
    ${toString width}x${toString height}^ \
    "$out/scaled/wallpaper-fraam-2021.png"

  convert ${./wallpaper-fraam-2021-dark-4096.png} -resize \
    ${toString width}x${toString height}^ \
    "$out/scaled/wallpaper-fraam-2021-dark.png"

  convert ${./win10lock.png} -resize \
    ${toString width}x${toString height}^ \
    "$out/scaled/win10lock.png"

  cp ${./wallpaper-n3-4096.png} $out/wallpaper-n3-4096.png
  cp ${./wallpaper-fraam-2021-4096.png} $out/wallpaper-fraam-2021-4096.png
  cp ${./wallpaper-fraam-2021-dark-4096.png} $out/wallpaper-fraam-2021-dark-4096.png
  cp ${./win10lock.png} $out/win10lock.png
''
