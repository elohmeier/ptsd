{ config, lib, pkgs, ... }:

with lib;

let
  readJSON = path: builtins.fromJSON (builtins.readFile path);
in
{
  options.ptsd.style = {

    # see https://github.com/base16-project/base16-schemes
    themeFile = mkOption {
      type = types.path;
      default = ./base16-schemes/selenized-black.json;
    };

    bemenuOpts = mkOption { type = types.str; };

    colors = {
      # optional
      background = mkOption { type = types.str; default = ""; };
      foreground = mkOption { type = types.str; default = ""; };

      base00 = mkOption { type = types.str; };
      base01 = mkOption { type = types.str; };
      base02 = mkOption { type = types.str; };
      base03 = mkOption { type = types.str; };
      base04 = mkOption { type = types.str; };
      base05 = mkOption { type = types.str; };
      base06 = mkOption { type = types.str; };
      base07 = mkOption { type = types.str; };
      base08 = mkOption { type = types.str; };
      base09 = mkOption { type = types.str; };
      base0A = mkOption { type = types.str; };
      base0B = mkOption { type = types.str; };
      base0C = mkOption { type = types.str; };
      base0D = mkOption { type = types.str; };
      base0E = mkOption { type = types.str; };
      base0F = mkOption { type = types.str; };

      # metadata
      author = mkOption { type = types.str; };
      scheme = mkOption { type = types.str; };
    };

    colorsHex = {
      background = mkOption { type = types.str; default = "#${config.ptsd.style.colors.background}"; };
      foreground = mkOption { type = types.str; default = "#${config.ptsd.style.colors.foreground}"; };

      base00 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base00}"; };
      base01 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base01}"; };
      base02 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base02}"; };
      base03 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base03}"; };
      base04 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base04}"; };
      base05 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base05}"; };
      base06 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base06}"; };
      base07 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base07}"; };
      base08 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base08}"; };
      base09 = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base09}"; };
      base0A = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base0A}"; };
      base0B = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base0B}"; };
      base0C = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base0C}"; };
      base0D = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base0D}"; };
      base0E = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base0E}"; };
      base0F = mkOption { type = types.str; default = "#${config.ptsd.style.colors.base0F}"; };
    };

  };

  config = {
    ptsd.style.colors = readJSON config.ptsd.style.themeFile;
    ptsd.style.bemenuOpts = with config.ptsd.style.colorsHex;"--fn \"Lucida Sans 10\" --nb \"${background}\" --nf \"${foreground}\" --tb \"${base01}\" --tf \"${base00}\" --hb \"${base0D}\" --hf \"${base00}\"";

    home.sessionVariables = lib.optionalAttrs (config.xsession.windowManager.i3.enable || config.wayland.windowManager.sway.enable) {
      BEMENU_OPTS = builtins.replaceStrings [ "\"" ] [ "\\\"" ] config.ptsd.style.bemenuOpts;
    };
  };
}
