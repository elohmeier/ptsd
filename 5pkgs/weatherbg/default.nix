{ writeShellScriptBin, wget, feh }:
writeShellScriptBin "weatherbg" ''
  ${wget}/bin/wget -O /tmp/bwk_bodendruck_na_ana.png https://www.dwd.de/DWD/wetter/wv_spez/hobbymet/wetterkarten/bwk_bodendruck_na_ana.png
  ${wget}/bin/wget -O /tmp/bwk_bodendruck_weu_ana.png https://www.dwd.de/DWD/wetter/wv_spez/hobbymet/wetterkarten/bwk_bodendruck_weu_ana.png

  ${feh}/bin/feh --image-bg "#8390A1" --bg-max /tmp/bwk_bodendruck_na_ana.png /tmp/bwk_bodendruck_weu_ana.png
''
