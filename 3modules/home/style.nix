{ config, lib, pkgs, ... }:

with lib;

let
  fromYAML = yaml:
    builtins.fromJSON (builtins.readFile (pkgs.runCommand "from-yaml"
      {
        inherit yaml;
        allowSubstitutes = false;
        preferLocalBuild = true;
      } ''
      ${pkgs.remarshal}/bin/remarshal  \
        -if yaml \
        -i <(echo "$yaml") \
        -of json \
        -o $out
    ''));

  readYAML = path: fromYAML (builtins.readFile path);
in
{
  options.ptsd.style = {

    # see https://github.com/base16-project/base16-schemes
    themeFile = mkOption {
      type = types.path;
      default = ./base16-schemes/selenized-black.yaml;
    };

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

  config.ptsd.style.colors = readYAML config.ptsd.style.themeFile;
}
