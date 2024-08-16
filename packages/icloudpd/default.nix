{
  buildPythonPackage,
  fetchFromGitHub,
  schema,
  click,
  python-dateutil,
  requests,
  tqdm,
  piexif,
  keyring,
  keyrings-alt,
  six,
  tzlocal,
  pytz,
  certifi,
  future,

}:

let
  pyicloud_ipd = buildPythonPackage rec {
    pname = "pyicloud_ipd";
    version = "0.10.1";
    src = fetchFromGitHub {
      owner = "icloud-photos-downloader";
      repo = "pyicloud";
      rev = "789930008342b37b3c9111437bf9348183df18c6";
      sha256 = "sha256-bnqnWeLkcQo1T2RxaevHgPdqd5d9dSlPOxxbxG98TPo=";
    };

    patchPhase = ''
      substituteInPlace requirements.txt \
        --replace 'keyrings.alt>=1.0,<2.0' 'keyrings.alt' \
        --replace 'keyring>=8.0,<9.0' 'keyring' \
        --replace 'click>=6.0,<7.0' 'click'
    '';

    propagatedBuildInputs = [
      requests
      keyring
      keyrings-alt
      click
      six
      tzlocal
      pytz
      certifi
      future
    ];

    doCheck = false;
  };
in
buildPythonPackage rec {
  pname = "icloudpd";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "icloud-photos-downloader";
    repo = "icloud_photos_downloader";
    rev = "v${version}";
    sha256 = "sha256-aRF8M3w39CNjEvFGX3PgKQq3PxLUCLcVz+H/Q/t0YKk=";
  };

  patchPhase = ''
    substituteInPlace requirements.txt \
      --replace 'tqdm==4.56.0' 'tqdm' \
      --replace 'schema==0.7.2' 'schema' \
      --replace 'click==6.7' 'click' \
      --replace 'python_dateutil==2.8.1' 'python_dateutil'
  '';

  propagatedBuildInputs = [
    pyicloud_ipd
    schema
    click
    python-dateutil
    requests
    tqdm
    piexif
  ];

  doCheck = false;
}
