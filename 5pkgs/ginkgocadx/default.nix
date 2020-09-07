{ stdenv, fetchFromGitHub, cmake, pkgconfig, wxGTK30, vtk_7, itk4, dcmtk, cairo, gtk2, curl, jsoncpp }:
let
  vtk = vtk_7.overrideAttrs (
    oldAttrs: {
      cMakeFlags = oldAttrs.cmakeFlags ++ [ "-DVTK_RENDERING_BACKEND=OpenGL" ];
    }
  );
in
stdenv.mkDerivation rec {
  pname = "ginkgocadx";
  version = "3.8.8";

  src = fetchFromGitHub {
    owner = "gerddie";
    repo = pname;
    rev = version;
    sha256 = "0qg36fn03h7g8l1p8qk1lihcrk50spsn0v3ix98w95z6vp0z7k7z";
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ wxGTK30 vtk itk4 dcmtk cairo gtk2 curl jsoncpp ];
}
