{ mariadb, fetchurl, pcre }:

mariadb.overrideAttrs (oldAttrs: rec {
  version = "10.4.15";
  src = fetchurl {
    urls = [
      "https://downloads.mariadb.com/MariaDB/mariadb-${version}/source/mariadb-${version}.tar.gz"
    ];
    sha256 = "0cdfzr768cb7n9ag9gqahr8c6igfn513md67xn4rf98ajmnxg0r7";
    name = "mariadb-${version}.tar.gz";
  };
  buildInputs = oldAttrs.buildInputs ++ [ pcre ];
})
