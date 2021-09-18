{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.firefox;
in
{
  options.ptsd.firefox = {
    enable = mkEnableOption "firefox";
    extraExtensions = mkOption {
      default = [ ];
      type = with types; listOf package;
    };
  };

  config = mkIf cfg.enable {

    programs.firefox = {
      enable = true;

      package = with pkgs; wrapFirefox firefox-esr-unwrapped {
        forceWayland = true;

        nixExtensions = with pkgs.ptsd-firefoxAddons; [
          ublock-origin
          auto-tab-discard
          browserpass
          cookie-autodelete
          tridactyl
          read-aloud
        ] ++ cfg.extraExtensions;

        # see https://github.com/mozilla/policy-templates/blob/master/README.md
        extraPolicies = {
          CaptivePortal = false;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;
          DontCheckDefaultBrowser = true;
          FirefoxHome = {
            Pocket = false;
            Snippets = false;
          };
          PasswordManagerEnabled = false;
          PromptForDownloadLocation = true;
          UserMessaging = {
            ExtensionRecommendations = false;
            SkipOnboarding = true;
          };
        };

        extraPrefs = ''
          // Show more ssl cert infos
          lockPref("security.identityblock.show_extended_validation", true);
        '';
      };

      profiles.default = { };
    };
  };
}