{ home-assistant }:

home-assistant.override {
  extraPackages = ps: with ps; [
    ps.google_api_python_client # for calendar integration
    ps.hass-nabucasa # required for mobile app
    ps.influxdb
    ps.paho-mqtt
    (ps.callPackage ../pyfritzhome {})
    ps.pyhomematic
    (ps.callPackage ../PyMetno {})
    ps.pynacl
    ps.pysonos
    ps.ssdp
    ps.zeroconf
  ];
}
