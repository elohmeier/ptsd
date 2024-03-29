{ writeScriptBin, checkSSLCert }:

writeScriptBin "prom-checktlsa" ''
  check_smtp() {
    labels="{host=\"$1\",port=\"$2\",protocol=\"smtp\"}"
    ${checkSSLCert}/bin/check_ssl_cert -H $1 -p $2 -P smtp --dane 1>&2
    echo check_ssl_cert_result''${labels} $?
    echo check_ssl_cert_completion_time''${labels} $(date +%s)
  }

  check_smtp htz2.nn42.de 25
''
