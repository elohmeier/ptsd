{ lib, stdenv, fetchFromGitHub, bluez }:

stdenv.mkDerivation rec {
  pname = "hidclient";
  version = "2017-02-20";

  src = fetchFromGitHub {
    owner = "benizi";
    repo = pname;
    rev = "e98caecfd780cbdbbcc56f488591e58e79bcd0f8";
    sha256 = "01lwrja0pz86rn15g27k40yshq1n9cr977y64ffv8n1hwnjiz7qk";
  };

  patches = [ ./rm-stropts.patch ];

  buildInputs = [ bluez ];

  installPhase = ''
    mkdir -p $out/bin
    cp hidclient $out/bin
  '';

  meta = with lib; {
    description = "Bluetooth HID client device emulation";
    license = licenses.gpl2;
    homepage = "https://github.com/benizi/hidclient";
    platforms = platforms.linux;
  };
}
