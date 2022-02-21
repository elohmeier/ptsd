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
      extraPackages = ps: with ps; [
        psycopg2
      ];
    };

  dlrg = hass.override
    {
      extraPackages = ps: with ps; [
        caldav
      ];
    };
}
