{ stdenv, glibc, gcc-unwrapped, autoPatchelfHook, fetchurl, libsecret, jre, makeWrapper, makeDesktopItem }:

let
  metadata = assert stdenv.hostPlatform.system == "i686-linux" || stdenv.hostPlatform.system == "x86_64-linux";
    if stdenv.hostPlatform.system == "i686-linux" then
      { arch = "x86"; sha256 = "0fdcapchg4zg25hn7kghf3i6hipw6cngn7v3cvnq2c9dndznvsxq"; }
    else
      { arch = "x86_64"; sha256 = "06jqq9fl4xf6c1a672hvkacx5p3x765pp1gxkl5f9lmi0pk506rf"; };
  desktopItem = makeDesktopItem {
    name = "Portfolio";
    exec = "portfolio";
    icon = "portfolio";
    comment = "Calculate Investment Portfolio Performance";
    desktopName = "Portfolio Performance";
    categories = "Application;Office;";
  };
in
stdenv.mkDerivation rec {
  pname = "PortfolioPerformance";
  version = "0.43.1";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/0.43.1/PortfolioPerformance-${version}-linux.gtk.${metadata.arch}.tar.gz";
    sha256 = metadata.sha256;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glibc
    gcc-unwrapped
    libsecret
  ];

  installPhase = ''
    mkdir -p $out/portfolio
    cp -av ./* $out/portfolio

    makeWrapper $out/portfolio/PortfolioPerformance $out/bin/portfolio \
      --prefix PATH : ${jre}/bin

    # Create desktop item
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    ln -s $out/portfolio/icon.xpm $out/share/pixmaps/portfolio.xpm
  '';

  meta = with stdenv.lib; {
    description = "A simple tool to calculate the overall performance of an investment portfolio.";
    homepage = "https://www.portfolio-performance.info/";
    license = licenses.epl10;
    maintainers = [ maintainers.elohmeier ];
  };
}
