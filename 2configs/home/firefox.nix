{ config, lib, pkgs, ... }: {

  programs.firefox = {
    enable = true;

    package = with pkgs; wrapFirefox firefox-esr-unwrapped {
      forceWayland = true;

      nixExtensions = with pkgs.ptsd-firefoxAddons; [
        ublock-origin
        auto-tab-discard
        browserpass
        cookie-autodelete
        darkreader
        tridactyl
        read-aloud
      ];

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

  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
