{ buildPythonPackage
, blobfile
, fetchPypi
, lib
, libiconv
, regex
, requests
, rustPlatform
, setuptools-rust
}:

buildPythonPackage rec {
  pname = "tiktoken";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-vTRmSUDvNR4SjbzuA/R1qMyEcZKRUtXB/QEkoGS4SRc=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src patches;
    name = "${pname}-${version}";
    hash = "sha256-WNq9+8Xj+mwPufn51H6LmvvyaSwJh6KkHKiqyR1XZgY=";
  };

  patches = [ ./Cargo.lock.patch ];

  doCheck = false;

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    rust.cargo
    rust.rustc
    setuptools-rust
  ];

  buildInputs = [
    libiconv
  ];

  propagatedBuildInputs = [
    blobfile
    regex
    requests
  ];
}
