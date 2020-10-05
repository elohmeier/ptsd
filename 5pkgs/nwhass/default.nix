{ home-assistant }:

home-assistant.override {
  extraPackages = ps: with ps; [
    ps.caldav
    ps.defusedxml # required for pyfritzhome
    ps.google_api_python_client # for calendar integration
    ps.hass-nabucasa # required for mobile app
    ps.gtts-token # for google tts
    ps.influxdb-client
    ps.influxdb
    ps.mutagen # for tts
    ps.netdisco # required by pyfritzhome
    ps.paho-mqtt
    ps.pyicloud
    ps.psycopg2
    ps.pyfritzhome
    ps.pyhomematic
    ps.pymetno
    ps.pynacl
    ps.ssdp
    ps.zeroconf
  ];
}
