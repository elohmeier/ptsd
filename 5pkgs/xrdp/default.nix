{ lib
, autoconf
, automake
, fetchFromGitHub
, fuse
, libjpeg
, libopus
, libtool
, nasm
, openssl
, pam
, perl
, pkg-config
, stdenv
, systemd
, which
, xorg
, xorgxrdp
}:

stdenv.mkDerivation rec {
  version = "0.9.19";
  pname = "xrdp";

  src = fetchFromGitHub {
    owner = "neutrinolabs";
    repo = "xrdp";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-wZ5OyGUdkD+PqtxB1j4l1bv56bWbOcqdBquzDS9USqo=";
  };

  nativeBuildInputs = [ pkg-config autoconf automake which libtool nasm ];

  buildInputs = [ openssl systemd pam fuse libjpeg libopus xorg.libX11 xorg.libXfixes xorg.libXrandr ];

  postPatch = ''
    substituteInPlace sesman/xauth.c --replace "xauth -q" "${xorg.xauth}/bin/xauth -q"
    substituteInPlace instfiles/pam.d/mkpamrules --replace "pam_module_dir_searchpath=\"" "pam_module_dir_searchpath=\"${pam}/lib/security\" #"
  '';

  preConfigure = ''
    (cd librfxcodec && ./bootstrap && ./configure --prefix=$out --enable-static --disable-shared)
    ./bootstrap
  '';
  dontDisableStatic = true;
  configureFlags = [
    "--enable-fuse"
    "--enable-ipv6"
    "--enable-jpeg"
    "--enable-opus"
    "--enable-rfxcodec"
    "--enable-strict-locations"
    "--sysconfdir=/run/xrdp"
    "--with-systemdsystemunitdir=/var/empty"
  ];

  installFlags = [ "DESTDIR=$(out)" "prefix=" ];

  postInstall = ''
    cp $src/keygen/openssl.conf $out/share/xrdp/openssl.conf
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "An open source RDP server";
    homepage = "https://github.com/neutrinolabs/xrdp";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
