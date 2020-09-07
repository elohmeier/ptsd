{ stdenv, fetchurl, dpkg, jre, libmatthew_java, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "dicomscope";
  version = "3.6.0";
  src = fetchurl {
    url = "mirror://debian/pool/main/d/dicomscope/dicomscope_${version}-20_all.deb";
    sha256 = "0vkwd6kb12jq9ll8vy7s0b7jmjpzhlrax2nnsppkx6jwmzcj8nxv";
  };
  buildInputs = [ makeWrapper ];
  nativeBuildInputs = [ dpkg ];
  unpackPhase = "dpkg-deb -x $src .";
  installPhase = ''
    mkdir -p $out/bin
    cp -a . $out

    makeWrapper ${jre}/bin/java $out/bin/dicomscope --add-flags "-Djava.library.path=${libmatthew_java}/lib/jni -jar $out/usr/share/java/DICOMscope-${version}.jar"
  '';
}
