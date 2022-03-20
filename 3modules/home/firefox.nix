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
      profiles.default = { };
    };
  };
}
