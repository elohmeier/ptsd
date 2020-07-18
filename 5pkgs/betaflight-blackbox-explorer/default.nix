{ stdenv, fetchurl, unzip, makeDesktopItem, nwjs, wrapGAppsHook, gsettings-desktop-schemas, gtk3 }:
let
  pname = "betaflight-blackbox-explorer";
  version = "3.5.0";
  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "Betaflight Blackbox Explorer";
    comment = "Crossplatform blackbox analitics tool for Betaflight flight control system";
    mimeType = "application/x-blackboxlog";
  };
  manifest = fetchurl {
    url = "https://raw.githubusercontent.com/betaflight/blackbox-log-viewer/${version}/manifest.json";
    sha256 = "1ll917x6kl4rim9r7bmy17lv5a5nz14a0s26lhq0rpa05qzmi4cy";
  };
  backgroundjs = fetchurl {
    url = "https://raw.githubusercontent.com/betaflight/blackbox-log-viewer/${version}/background.js";
    sha256 = "0b15l6gx1v2s0cf11r931q050s7xm32iixi7sbx29z3l3ya8jy3j";
  };
in
stdenv.mkDerivation rec {
  inherit pname version;
  src = fetchurl {
    url = "https://github.com/betaflight/blackbox-log-viewer/releases/download/${version}/${pname}_${version}_linux64.zip";
    sha256 = "0pjwy8n58fyzcacvjpk2wm4hwj2i0k5rxpvhy8xlx0jlw9r1ndir";
  };

  nativeBuildInputs = [ wrapGAppsHook ];

  buildInputs = [ unzip gsettings-desktop-schemas gtk3 ];

  installPhase = ''
    mkdir -p $out/bin \
             $out/opt/${pname}
    
    cp -r . $out/opt/${pname}/
    install -m 444 -D icon/bf_icon_128.png $out/share/icons/hicolor/128x128/apps/${pname}.png
    cp -r ${desktopItem}/share/applications $out/share/
    cp ${manifest} $out/opt/${pname}/manifest.json
    cp ${backgroundjs} $out/opt/${pname}/background.js
    mkdir -p $out/opt/${pname}/_locales
    
    makeWrapper ${nwjs}/bin/nw $out/bin/${pname} --add-flags $out/opt/${pname}
  '';

  meta.broken = true;
}
