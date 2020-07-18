{ writeShellScriptBin, alacritty }:

writeShellScriptBin "osx-fix-alacritty" ''
  tic -xe alacritty,alacritty-direct ${alacritty.src}/extra/alacritty.info
''
