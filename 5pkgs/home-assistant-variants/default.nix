{ home-assistant, fetchFromGitHub }:

let
  # skip install checks as in NixOS hass module
  hass = home-assistant.overrideAttrs (oldAttrs: {
    doInstallCheck = false;
  });
in
{
  bs53 = hass.override
    {
      # extraComponents = [
      #   "brother"
      #   "dwd_weather_warnings"
      #   "fritzbox"
      #   "ipp"
      #   "met"
      #   "mobile_app"
      #   "mqtt"
      #   "prometheus"
      #   "sonos"
      #   "spotify"
      #   "ssdp"
      #   "tts"
      #   "recorder"
      #   "homematic"
      # ];
      extraPackages = ps: with ps; [
        ps.psycopg2
      ];
    };

  dlrg = hass.override
    {
      extraComponents = [
        "caldav"
        "dwd_weather_warnings"
        "fritzbox"
        "frontend"
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
