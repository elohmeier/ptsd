{ lib
, stdenv
, fetchFromBitbucket
, pkg-config
, cmake
, pixman
, libpthreadstubs
, gtkmm3
, libXau
, libXdmcp
, lcms2
, libiptcdata
, libcanberra-gtk3
, fftwSinglePrec
, expat
, pcre
, libsigcxx
, wrapGAppsHook
, lensfun
, librsvg
, exiv2
}:

stdenv.mkDerivation rec {
  version = "1.12";
  pname = "art";

  src = fetchFromBitbucket {
    owner = "agriggio";
    repo = "art";
    rev = version;
    sha256 = "sha256-6xLpA1UjWm9fHDH70ti1IlaNsT8v5iVJvaI31rg4JBg=";
  };

  nativeBuildInputs = [ cmake pkg-config wrapGAppsHook ];

  buildInputs = [
    pixman
    libpthreadstubs
    gtkmm3
    libXau
    libXdmcp
    lcms2
    libiptcdata
    libcanberra-gtk3
    fftwSinglePrec
    expat
    pcre
    libsigcxx
    lensfun
    librsvg
    exiv2
  ];

  cmakeFlags = [
    "-DPROC_TARGET_NUMBER=2"
    "-DCACHE_NAME_SUFFIX=\"\""
  ];

  CMAKE_CXX_FLAGS = "-std=c++11 -Wno-deprecated-declarations -Wno-unused-result";

  postUnpack = ''
    echo "set(HG_VERSION $version)" > $sourceRoot/ReleaseInfo.cmake
  '';

  meta = {
    description = "RAW converter and digital photo processing software";
    homepage = "https://bitbucket.org/agriggio/art/wiki/Home/";
  };
}
