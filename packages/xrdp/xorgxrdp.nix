{
  stdenv,
  autoconf,
  automake,
  fetchFromGitHub,
  libtool,
  nasm,
  pkg-config,
  which,
  xorg,
  xrdp,
}:

stdenv.mkDerivation rec {
  pname = "xorgxrdp";
  version = "0.2.18";

  src = fetchFromGitHub {
    owner = "neutrinolabs";
    repo = "xorgxrdp";
    rev = "v${version}";
    sha256 = "sha256-veRzHQklkjoHIy5xowd4UI1e5ZxBbSsElYd4vE+LiJ4=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    which
    libtool
    nasm
  ];

  buildInputs = [ xorg.xorgserver ];

  postPatch = ''
    # patch from Debian, allows to run xrdp daemon under unprivileged user
    substituteInPlace module/rdpClientCon.c \
      --replace 'g_sck_listen(dev->listen_sck);' 'g_sck_listen(dev->listen_sck); g_chmod_hex(dev->uds_data, 0x0660);'

    substituteInPlace configure.ac \
      --replace 'moduledir=`pkg-config xorg-server --variable=moduledir`' "moduledir=$out/lib/xorg/modules" \
      --replace 'sysconfdir="/etc"' "sysconfdir=$out/etc"
  '';

  preConfigure = "./bootstrap";

  configureFlags = [ "XRDP_CFLAGS=-I${xrdp.src}/common" ];

  enableParallelBuilding = true;
}
