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
    #"sonos"  # TODO: wait for https://github.com/NixOS/nixpkgs/pull/118027
    "spotify"
    "ssdp"
    "tts"
    "recorder"
    "homematic"
  ];
  extraPackages = ps: with ps; [
    ps.psycopg2
  ];
}
