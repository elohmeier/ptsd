{ stdenv, fetchFromGitHub, pkg-config, automake, autoconf, bash, libtool, gnome2, intltool, gtkmm2 }:

stdenv.mkDerivation rec {
  pname = "aeskulap";
  version = "2014-01-19";

  src = fetchFromGitHub {
    owner = "pipelka";
    repo = pname;
    rev = "ea0a119985e276352719c8438804c2a285e61e5e";
    sha256 = "0p43kaavh4zzhacjyqmy0mwqdf6w5v8cxg1apj3z5z0kq5q1lm14";
  };

  nativeBuildInputs = [ pkg-config automake autoconf libtool intltool ];

  prePatch = ''
    substituteInPlace autogen.sh \
      --replace "/bin/bash" "${bash}/bin/bash"
  '';

  preConfigure = "./autogen.sh";

  buildInputs = [ gnome2.GConf gtkmm2 gnome2.libglademm ];
}
