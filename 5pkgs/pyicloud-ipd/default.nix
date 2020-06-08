{ lib
, buildPythonPackage
, fetchPypi
, requests
, keyring
, keyrings-alt
, click
, six
, tzlocal
, certifi
, bitstring
, unittest2
, future
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "pyicloud-ipd";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "ndbroadbent";
    repo = "pyicloud";
    rev = "37e25bd41e2e5b00a43dccd0f5fa4399849fcc2e";
    sha256 = "1k9mdivhiwn3gnc7nwyx9z8wy6jbggxc0mxswwc3h3nxpm1g4ar6";
  };

  propagatedBuildInputs = [
    requests
    keyring
    keyrings-alt
    click
    six
    tzlocal
    certifi
    bitstring
    future
  ];

  checkInputs = [ unittest2 ];

  postPatch = ''
    sed -i \
      -e 's!click>=6.0,<7.0!click!' \
      -e 's!keyring>=8.0,<9.0!keyring!' \
      -e 's!keyrings.alt>=1.0,<2.0!keyrings.alt!' \
      requirements.txt
  '';

  meta = with lib; {
    description = "PyiCloud patched for icloud-photos-downloader";
  };
}
