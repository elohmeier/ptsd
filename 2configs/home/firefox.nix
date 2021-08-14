{ config, lib, pkgs, ... }: {

  programs.firefox = {
    enable = true;

    package = with pkgs; wrapFirefox firefox-unwrapped {
      nixExtensions = [
        (fetchFirefoxAddon {
          name = "ublock_origin";
          url = "https://addons.mozilla.org/firefox/downloads/file/3816867/ublock_origin-1.37.2-an+fx.xpi";
          sha256 = "sha256-2e73AbmYZlZXCP5ptYVcFjQYdjDp4iPoEPEOSCVF5sA=";
        })

        (fetchFirefoxAddon {
          name = "auto_tab_discard";
          url = "https://addons.mozilla.org/firefox/downloads/file/3767563/auto_tab_discard-0.4.7-an+fx.xpi";
          sha256 = "sha256-Ov16BZlQecfGR8egGgfdAzseR+57VoRuM+LZSasQyYo=";
        })

        # browserpass
        # cookie autodelete
        # dark reader
        # tridactyl
        # read aloud
      ];

      extraPolicies = {
        CaptivePortal = false;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = true;
        FirefoxHome = {
          Pocket = false;
          Snippets = false;
        };
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
  };


  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };
}
