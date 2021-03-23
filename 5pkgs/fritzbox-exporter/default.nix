{ python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "fritzbox_exporter";
  version = "1.0.4";

  src = fetchFromGitHub
    {
      owner = "pdreker";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-wP6ByBCOaBuhTylwxyNfZeyIr5w0kjvyxpswqBIyt30=";
    };

  postPatch = ''
    sed '1i#!/usr/bin/env python3' -i \
      fritz_export_helper.py \
      fritz_exporter.py
    cp ${./setup.py} ./setup.py
  '';

  propagatedBuildInputs = with python3Packages; [ prometheus_client fritzconnection ];
}
