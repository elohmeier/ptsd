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
      package = pkgs.firefox-config-desktop.override {
        extraExtensions = cfg.extraExtensions;
      };

      profiles.privacy = {
        id = 0; # 0=default
      };

      profiles.office = {
        id = 1;

        settings = {
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
    };
  };
}
