{ home-assistant }:

home-assistant.override {
  extraPackages = ps: with ps; [
    (
      # waits for https://github.com/NixOS/nixpkgs/pull/85686
      ps.caldav.overrideAttrs (
        old: {
          # xandikos is only a optional test dependency,
          # not available for python3
          postPatch = ''
            substituteInPlace setup.py \
              --replace ", 'xandikos'" ""
          '';
          meta.broken = false;
        }
      )
    )
    ps.google_api_python_client # for calendar integration
    ps.hass-nabucasa # required for mobile app
    ps.gtts-token # for google tts
    ps.influxdb
    ps.mutagen # for tts
    ps.paho-mqtt
    ps.psycopg2
    (ps.callPackage ../pyfritzhome {})
    (
      # use latest version
      ps.pyhomematic.overrideAttrs (
        old: rec {
          pname = "pyhomematic";
          version = "0.1.66";
          src = ps.fetchPypi {
            inherit pname version;
            sha256 = "0yaxmnd0w1a6ckvc6rf0j2wmjd1x2f5dw1bbdzm1m2pf0s2dniph";
          };
        }
      )
    )
    (ps.callPackage ../PyMetno {})
    ps.pynacl
    (
      # seems to work again as of 2020-05-01
      ps.pysonos.overrideAttrs (old: { meta.broken = false; })
    )
    ps.ssdp
    ps.zeroconf
  ];
}
