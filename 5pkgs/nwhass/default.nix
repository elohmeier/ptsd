{ home-assistant }:

home-assistant.override {
  extraComponents = [
    "brother"
    "caldav"
    "dwd_weather_warnings"
    "fritzbox"
    "google"
    "google_translate"
    "ipp"
    "met"
    "mobile_app"
    "mqtt"
    "prometheus"
    #"sonos"  # TODO: broken
    "spotify"
    "ssdp"
    "tts"
  ];
  extraPackages = ps: with ps; [
    ps.psycopg2
  ];
}
