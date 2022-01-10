{ stdenv, fetchurl, unzip, qemu-utils }:

stdenv.mkDerivation rec {
  pname = "windows-vm-image";
  version = "WinDev2112Eval";

  # https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/
  src = fetchurl {
    url = "https://download.microsoft.com/download/9/0/8/90881435-55c1-4cf2-81f8-aae807702467/${version}.HyperVGen1.zip";
    sha256 = "14k6gji9szsljk98ag2fv2y1inf8r0zhhhrplqh2rnrlnajskg8m";
  };
  sourceRoot = "Virtual Hard Disks";

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir $out
    ${qemu-utils}/bin/qemu-img convert -f vpc -O qcow2 "${version}.vhd" $out/windows-vm-image.qcow2
  '';
}
