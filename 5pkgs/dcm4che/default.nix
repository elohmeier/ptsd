{ stdenv, fetchFromGitHub, jdk, jre, maven, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "dcm4che";
  version = "5.22.3";
  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "0ign19y7h7qifv86pk563fxvrw6qzg6qlcxzns0mqwxnccx4kq64";
  };

  deps = stdenv.mkDerivation {
    name = "${pname}-${version}-deps";
    inherit src;
    nativeBuildInputs = [ jdk maven ];
    installPhase = ''
      # Download the dependencies
      while ! mvn package "-Dmaven.repo.local=$out/.m2" -Dmaven.wagon.rto=5000; do
        echo "timeout, restart maven to continue downloading"
      done

      # And keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files
      # with lastModified timestamps inside
      find "$out/.m2" -type f \
        -regex '.+\(\.lastUpdated\|resolver-status\.properties\|_remote\.repositories\)' \
        -delete
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "13r5xr00s2m50ki5ri8jjb6qzf7l779mr0h3rx6lsxhq36j88642";
  };

  nativeBuildInputs = [ makeWrapper jdk maven ];

  buildPhase = ''
    cp -dpR "${deps}/.m2" ./
    chmod -R +w .m2
    mvn package --offline -Dmaven.repo.local="$(pwd)/.m2"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -a . $out

    makeWrapper ${jre}/bin/java $out/bin/dcm2jpg --add-flags "-jar $out/dcm4che-tool/dcm4che-tool-dcm2jpg/target/dcm4che-tool-dcm2jpg-5.22.3.jar"
  '';
}
