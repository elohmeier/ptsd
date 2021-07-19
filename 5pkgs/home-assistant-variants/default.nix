{ home-assistant, fetchFromGitHub }:

let
  # skip install checks as in NixOS hass module
  hass = home-assistant.overrideAttrs (oldAttrs: {
    doInstallCheck = false;

    patches = [
      ./2021.5.5-fritzbox-lightbulb.patch
    ];
  });
in
{
  bs53 = hass.override
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

  dlrg = hass.override
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

      packageOverrides = self: super: {
        pyfritzhome = super.pyfritzhome.overridePythonAttrs (oldAttrs: rec {
          version = "0.6.2";
          src = fetchFromGitHub {
            owner = "hthiery";
            repo = "python-fritzhome";
            rev = version;
            sha256 = "sha256-OyhprqNv1tUcEfO/Dc32Izdfl7JDmHsf8jNWXHjCncM=";
          };
        });
      };
    };
}
