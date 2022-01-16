{ stdenv, fetchFromSourcehut, coreutils }:

stdenv.mkDerivation rec {
  pname = "sxmo-utils";
  version = "1.7.1";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = pname;
    rev = version;
    sha256 = "sha256-kRosu2Hc2Zv47WpsCruZ9AwkYN3LWxwO4l5lApGvF4w=";
  };

  postPatch = ''
    substituteInPlace scripts/core/sxmo_common.sh \
      --replace 'alias jq="gojq"' '#alias jq="gojq"'

    substituteInPlace configs/udev/90-sxmo.rules \
      --replace '/usr/bin/sxmo_statusbarupdate.sh' "$out/bin/sxmo_statusbarupdate.sh" \
      --replace '/bin/chgrp' "${coreutils}/bin/chgrp" \
      --replace '/bin/chmod' "${coreutils}/bin/chmod"
  '';

  installFlags = [ "DESTDIR=$(out)" ];

  postInstall = ''
    mv $out/usr/* $out/
    rm -rf $out/usr

    mkdir -p $out/lib
    mv $out/etc/udev $out/lib/
  '';
}
