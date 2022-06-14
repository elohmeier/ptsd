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
      default = ./base16-schemes/windows-10.yaml;
    };

    colors = mkOption { type = types.attrs; };

  };

  config.ptsd.style.colors = readYAML config.ptsd.style.themeFile;
}
