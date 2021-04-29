{ home-assistant }:
{
  bs53 = home-assistant.override
    {
      extraComponents = [
        "brother"
        "dwd_weather_warnings"
        "fritzbox"
        "ipp"
        "met"
        "mobile_app"
        "mqtt"
        "prometheus"
        "sonos"
        "spotify"
        "ssdp"
        "tts"
        "recorder"
        "homematic"
      ];
      extraPackages = ps: with ps; [
        ps.psycopg2
      ];
    };

  dlrg = home-assistant.override
    {
      extraComponents = [
        "caldav"
        "dwd_weather_warnings"
        "fritzbox"
        "met"
        "mobile_app"
        "mqtt"
        "prometheus"
        "ssdp"
        "recorder"
        "homematic"
      ];
    };
}
