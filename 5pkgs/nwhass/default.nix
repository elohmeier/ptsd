{ home-assistant }:

home-assistant.override {
  extraPackages = ps: with ps; [
    ps.brother
    ps.caldav
    ps.defusedxml # required by pyfritzhome
    ps.emoji # required by mobile_app integration
    ps.google_api_python_client # for calendar integration
    ps.hass-nabucasa # required by mobile app
    ps.gtts-token # for google tts
    ps.influxdb-client
    ps.influxdb
    ps.jsonpath # required by dwd integration
    ps.mutagen # for tts
    ps.netdisco # required by pyfritzhome
    ps.paho-mqtt
    # ps.pyicloud # disabled because of annoying popups 2020-10-30
    ps.pyipp
    ps.psycopg2
    ps.pyfritzhome
    ps.pyhomematic
    ps.pymetno
    ps.pynacl
    ps.pysonos
    ps.spotipy
    ps.ssdp
    ps.zeroconf
    ps.prometheus_client
  ];
}
