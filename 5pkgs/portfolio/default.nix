{ stdenv, glibc, gcc-unwrapped, autoPatchelfHook, fetchurl, libsecret, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "PortfolioPerformance";
  version = "0.43.1";

  src = fetchurl {
    url = "https://github.com/buchen/portfolio/releases/download/0.43.1/PortfolioPerformance-${version}-linux.gtk.x86_64.tar.gz";
    sha256 = "06jqq9fl4xf6c1a672hvkacx5p3x765pp1gxkl5f9lmi0pk506rf";
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

    makeWrapper $out/portfolio/PortfolioPerformance $out/bin/PortfolioPerformance \
      --prefix PATH : ${jre}/bin
  '';

  meta = with stdenv.lib; {
    description = "A simple tool to calculate the overall performance of an investment portfolio.";
    homepage = "https://www.portfolio-performance.info/";
    license = licenses.epl10;
    maintainers = [ maintainers.elohmeier ];
    platforms = [ "x86_64-linux" ];
  };
}
