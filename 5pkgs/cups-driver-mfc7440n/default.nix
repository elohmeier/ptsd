{ lib, stdenv, pkgsi686Linux, fetchurl, cups, dpkg, gnused, makeWrapper, ghostscript, file, a2ps, coreutils, gawk }:

let
  version = "2.0.2-1";
  cupsdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf006251/cupswrapperMFC7440N-${version}.i386.deb";
    sha256 = "sha256-YOD8KFfsZcYbQILFKlWztl1CuwAu+SeKSeW2pxfCHV8=";
  };
  lprdeb = fetchurl {
    url = "https://download.brother.com/welcome/dlf006249/brmfc7440nlpr-${version}.i386.deb";
    sha256 = "sha256-WheEwXlE3Ks2uT11krLjuEEci2pxLPXYlxrCsIpAZXc=";
  };
in
stdenv.mkDerivation {
  pname = "cups-brother-mfc7440n";
  inherit version;

  srcs = [ lprdeb cupsdeb ];
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ cups ghostscript dpkg a2ps ];
  dontUnpack = true;

  installPhase = ''
    # install lpr
    dpkg-deb -x ${lprdeb} $out

    substituteInPlace $out/usr/local/Brother/lpd/filterMFC7440N \
      --replace /usr "$out/usr"

    sed -i '/GHOST_SCRIPT=/c\GHOST_SCRIPT=gs' $out/usr/local/Brother/lpd/psconvert2

    patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $out/usr/bin/brprintconflsr2
    patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $out/usr/local/Brother/lpd/rawtobr2
    patchelf --set-interpreter ${pkgsi686Linux.glibc.out}/lib/ld-linux.so.2 $out/usr/local/Brother/inf/braddprinter

    wrapProgram $out/usr/local/Brother/lpd/psconvert2 \
      --prefix PATH ":" ${ lib.makeBinPath [ gnused coreutils gawk ] }
    wrapProgram $out/usr/local/Brother/lpd/filterMFC7440N \
      --prefix PATH ":" ${ lib.makeBinPath [ ghostscript a2ps file gnused coreutils ] }

    # install cups
    dpkg-deb -x ${cupsdeb} $out

    substituteInPlace $out/usr/local/Brother/cupswrapper/cupswrapperMFC7440N-2.0.2 --replace /usr "$out/usr"

    mkdir -p $out/lib/cups/filter
    ln -s $out/usr/local/Brother/cupswrapper/cupswrapperMFC7440N-2.0.2 $out/lib/cups/filter/cupswrapperMFC7440N-2.0.2
    ln -s $out/usr/local/Brother/cupswrapper/brcupsconfig3 $out/lib/cups/filter/brcupsconfig3

    wrapProgram $out/usr/local/Brother/cupswrapper/cupswrapperMFC7440N-2.0.2 \
      --prefix PATH ":" ${ lib.makeBinPath [ gnused coreutils gawk ] }
  '';

  meta = {
    homepage = "http://www.brother.com/";
    description = "Brother HL1210W printer driver";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=nz&lang=en&prod=hl1210w_eu_as&os=128";
  };
}
