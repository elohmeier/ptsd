{ config, lib, pkgs, ... }:

with lib;
let
  lwcfg = lib.importJSON ../../5pkgs/firefox-configs/librewolf.json;
in
{
  programs.firefox = {
    enable = true;

    package = pkgs.firefox-bin;

    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      browserpass
      surfingkeys
      ublock-origin
    ];

    profiles.privacy = {
      id = 0; # 0=default
      settings = lwcfg;
    };

    profiles.office = {
      id = 1;

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

  home.packages = [
    (pkgs.writeShellScriptBin "firefox-privacy" "firefox -P privacy")
    (pkgs.writeShellScriptBin "firefox-office" "firefox -P office")
    (pkgs.writeShellScriptBin "firefox-burp" "firefox -P burp")
  ];

  # restore ublock backup
  home.file =
    let
      dir = if pkgs.stdenv.isDarwin then "Library/Application Support/Mozilla/ManagedStorage" else ".mozilla/managed-storage";
      # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin
      ublockJson = pkgs.writeText "ublock.json" (builtins.toJSON {
        name = "uBlock0@raymondhill.net";
        description = "ignored";
        type = "storage";
        # backup conversion similar to http://raymondhill.net/ublock/adminSetting.html
        data.adminSettings = builtins.readFile (pkgs.runCommand "ublock-config-backup" { preferLocalBuild = true; } "cat ${../../5pkgs/firefox-configs/my-ublock-backup.txt} | ${pkgs.jq}/bin/jq -c > $out");
      });
    in
    {
      "${dir}/uBlock0@raymondhill.net.json".source = ublockJson;
    };
}
