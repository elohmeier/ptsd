{ stdenv, fetchFromGitLab }:

stdenv.mkDerivation rec {
  pname = "mobile-config-firefox";
  version = "3.0.0";

  src = fetchFromGitLab {
    owner = "postmarketOS";
    repo = pname;
    rev = version;
    sha256 = "sha256-Ius8b0z/FpDeOc0iKyUNNUJIqNrr7hYfT8fdQ+2KUqQ=";
  };

  postPatch = ''
    substituteInPlace src/mobile-config-prefs.js \
      --replace '"mobile-config-autoconfig.js"' "\"$out/usr/lib/firefox/mobile-config-autoconfig.js\""

    substituteInPlace src/mobile-config-autoconfig.js \
      --replace "/etc/mobile-config-firefox/" "$out/etc/mobile-config-firefox/"
  '';

  installFlags = [ "DESTDIR=$(out)" ];
}
