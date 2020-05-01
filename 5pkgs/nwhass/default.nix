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
    ps.influxdb
    ps.paho-mqtt
    (ps.callPackage ../pyfritzhome {})
    ps.pyhomematic
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
