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
    substituteInPlace fritz_exporter.py --replace \
      "start_http_server(int(port))" \
      "start_http_server(int(port), os.getenv('FRITZ_EXPORTER_ADDRESS', '127.0.0.1'))"
    cp ${./setup.py} ./setup.py
  '';

  propagatedBuildInputs = with python3Packages; [ prometheus_client fritzconnection ];
}
