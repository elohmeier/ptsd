{ lib, pkgs, ... }:

with lib;
let
  lwcfg = lib.importJSON ../../5pkgs/firefox-configs/librewolf.json;
  # see https://github.com/mozilla/policy-templates/blob/master/README.md
  # https://gitlab.com/librewolf-community/settings/-/blob/master/distribution/policies.json
  policies = {
    AppUpdateUrl = "https://localhost";
    DisableAppUpdate = true;
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";
    DisableSystemAddonUpdate = true;
    DisableProfileImport = false;
    DisableFirefoxStudies = true;
    DisableTelemetry = true;
    DisableFeedbackCommands = true;
    DisablePocket = true;
    DisableSetDesktopBackground = false;
    DisableDeveloperTools = false;
    DNSOverHttps = {
      Enabled = false;
      ProviderURL = "";
      Locked = false;
    };
    NoDefaultBookmarks = true;
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
    # interferes with nixExtensions in wrapFirefox
    Extensions = {
      Install = [
        "https://addons.mozilla.org/firefox/downloads/file/3711209/browserpass-3.7.2-fx.xpi"

        # see https://librewolf.net/docs/faq/#why-is-librewolf-forcing-light-theme
        # "https://addons.mozilla.org/firefox/downloads/file/3904618/dark_reader-4.9.45-an+fx.xpi"

        "https://addons.mozilla.org/firefox/downloads/file/3933192/ublock_origin-1.42.4.xpi"
        "https://addons.mozilla.org/firefox/downloads/file/3904477/surfingkeys-1.0.4-fx.xpi"
      ];

      Uninstall = [
        "google@search.mozilla.org"
        "bing@search.mozilla.org"
        "amazondotcom@search.mozilla.org"
        "ebay@search.mozilla.org"
        "twitter@search.mozilla.org"
      ];
    };
  };
in
{
  programs.firefox = {
    enable = true;

    package =
      if pkgs.stdenv.isDarwin then
        pkgs.firefox-bin.override { inherit policies; }
      else
        pkgs.firefox.override {
          applicationName = "firefox";
          extraPolicies = policies;
        };

    profiles.office = {
      id = 0; # 0=default

      settings = lwcfg // {
        # keep login info
        "privacy.resistFingerprinting" = false;
        "privacy.resistFingerprinting.letterboxing" = false;
        "privacy.sanitize.sanitizeOnShutdown" = false;
        "network.cookie.lifetimePolicy" = 0;

        # fix video conferencing
        "webgl.disabled" = false;
        "media.peerconnection.ice.no_host" = false;
        "media.autoplay.blocking_policy" = 0;
        "media.autoplay.default" = 0;
      };
    };

    profiles.privacy = {
      id = 1;
      settings = lwcfg;
    };

    profiles.burp = {
      id = 2;

      settings = lwcfg // {
        "network.proxy.http" = "127.0.0.1";
        "network.proxy.http_port" = 8080;
        "network.proxy.type" = 1;
        "network.proxy.share_proxy_settings" = true;
      };
    };
  };

  programs.browserpass.enable = true;

  home.packages = [
    (pkgs.writeShellScriptBin "firefox-privacy" "firefox -P privacy")
    (pkgs.writeShellScriptBin "firefox-office" "firefox -P office")
    (pkgs.writeShellScriptBin "firefox-burp" "firefox -P burp")
  ];

  # restore ublock backup
  home.file =
    let
      dir =
        if pkgs.stdenv.isDarwin then
          "Library/Application Support/Mozilla/ManagedStorage"
        else
          ".mozilla/managed-storage";
      # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin
      ublockJson = pkgs.writeText "ublock.json" (
        builtins.toJSON {
          name = "uBlock0@raymondhill.net";
          description = "ignored";
          type = "storage";
          # backup conversion similar to http://raymondhill.net/ublock/adminSetting.html
          data.adminSettings = builtins.readFile (
            pkgs.runCommand "ublock-config-backup" {
              preferLocalBuild = true;
            } "cat ${../../5pkgs/firefox-configs/my-ublock-backup.txt} | ${pkgs.jq}/bin/jq -c > $out"
          );
        }
      );
    in
    {
      "${dir}/uBlock0@raymondhill.net.json".source = ublockJson;
    };
}
