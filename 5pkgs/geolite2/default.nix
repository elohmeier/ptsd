{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "GeoLite2";
  version = "20191119"; # last Tuesday

  src = [
    (
      fetchurl {
        url = "https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz";
        sha256 = "07jc6r9db9m4s9bbwar391fjlxsk8a01b0bph793a4wqrmr509v7";
      }
    )
    (
      fetchurl {
        url = "https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz";
        sha256 = "1jkgywdwshabj3w1jdlhn5272r3c1y68lk9rkxp0kgyg93bcsij6";
      }
    )
  ];

  sourceRoot = "GeoLite2-Country_${version}";

  dontPatchShebangs = true;

  installPhase = ''
    mkdir -p $out/share/geoip
    cp -v GeoLite2-Country.mmdb $out/share/geoip/GeoLite2-Country.mmdb
    cp -v ../GeoLite2-City_${version}/GeoLite2-City.mmdb $out/share/geoip/GeoLite2-City.mmdb
  '';
}
