{ fetchFromGitHub, stdenv, gtk3 }:

stdenv.mkDerivation rec {
  pname = "chicago95";
  version = "2020-02-24";

  src = fetchFromGitHub {
    owner = "grassmunk";
    repo = pname;
    rev = "bfe7aec02c5141abf9ece2b0393435819ea13eba";
    sha256 = "1qh7im3jdq7d1gw0i85w8gqmx0mb49wvq2pdrm68wvl8x44lllr7";
  };

  dontBuild = true;

  nativeBuildInputs = [ gtk3 ];

  installPhase = ''
    install -dm 755 "$out/share/themes/"
    cp -dr --no-preserve='ownership' Theme/Chicago95 "$out/share/themes/"

    install -dm 755 "$out/share/lightdm-webkit/themes/"
    cp -dr --no-preserve='ownership' Lightdm/Chicago95 "$out/share/lightdm-webkit/themes/"

    install -dm 755 "$out/share/icons/"
    cp -dr --no-preserve='ownership' Icons/* "$out/share/icons/"
    cp -dr --no-preserve='ownership' Cursors/* "$out/share/icons/"

    install -dm 755 "$out/share/fonts/truetype/ms_sans_serif/"
    cp -dr --no-preserve='ownership' Fonts/* "$out/share/fonts/truetype/"
    cp -dr --no-preserve='ownership' ${./micross.ttf} "$out/share/fonts/truetype/ms_sans_serif/"
    cp -dr --no-preserve='ownership' ${./MSSansSerif.ttf} "$out/share/fonts/truetype/ms_sans_serif/"

    install -dm 755 "$out/etc/fonts/conf.d/"
    cp -d --no-preserve='ownership' Extras/99-ms-sans-serif-bold.conf "$out/etc/fonts/conf.d/"
    cp -d --no-preserve='ownership' Extras/99-ms-sans-serif.conf "$out/etc/fonts/conf.d/"

    install -dm 755 "$out/share/xfce4/terminal/colorschemes/"
    cp -d --no-preserve='ownership' Extras/Chicago95.theme "$out/share/xfce4/terminal/colorschemes/"

    cp -d --no-preserve='ownership' Extras/DOSrc "$out/share/"

    install -dm 755 "$out/share/plymouth/themes/"
    cp -dr --no-preserve='ownership' Plymouth/Chicago95 "$out/share/plymouth/themes/"
    cp -dr --no-preserve='ownership' Plymouth/RetroTux "$out/share/plymouth/themes/"
  '';

  postFixup = ''
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';
}
