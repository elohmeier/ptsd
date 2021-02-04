{ stdenv, lib, fetchFromGitHub, libjpeg, libevent, libuuid, libbsd, libraspberrypi }:

stdenv.mkDerivation rec {
  pname = "ustreamer";

  version = "1.19";

  src = fetchFromGitHub {
    owner = "pikvm";
    repo = pname;
    rev = "v${version}";
    sha256 = "0w9ixrq076sqvddvg5njv5llxyraf7q5y09yvzzwsxdr8jjlfk62";
  };

  buildInputs = [ libjpeg libevent libuuid libbsd ] ++ lib.optional (stdenv.targetPlatform.system == "aarch64-linux") [ libraspberrypi ];

  makeFlags = [
    "PREFIX=$(out)"
  ] ++ lib.optional (stdenv.targetPlatform.system == "aarch64-linux") [
    # not working yet
    # "WITH_OMX=1" 
  ];

  meta = with lib; {
    homepage = "https://github.com/pikvm/ustreamer";
    description = "Lightweight and fast MJPG-HTTP streamer";
    license = licenses.gpl3;
    maintainers = with maintainers; [ elohmeier ];
  };
}
