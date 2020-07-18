{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.i3status-rust;

  configFile =
    pkgs.runCommand "i3status-config.toml"
      {
        buildInputs = [ pkgs.remarshal ];
        preferLocalBuild = true;
      } ''
      remarshal -if json -of toml \
        < ${pkgs.writeText "config.json"
        (builtins.toJSON cfg.config)} \
        > $out
    '';
in
{
  options.ptsd.i3status-rust = {
    enable = mkEnableOption "i3status-rust";
    package = mkOption {
      type = types.package;
      default = pkgs.i3status-rust;
    };
    config = mkOption {
      type = types.attrs;
      example = {
        theme = "solarized-dark";
        icons = "awesome";
        block = [
          {
            block = "disk_space";
            path = "/";
            alias = "/";
            info_type = "available";
            unit = "GB";
            interval = 20;
            warning = 20.0;
            alert = 10.0;
          }
          {
            block = "memory";
            display_type = "memory";
            format_mem = "{Mup}%";
            format_swap = "{SUp}%";
          }
          {
            block = "cpu";
            interval = 1;
          }
          {
            block = "load";
            interval = 1;
            format = "{1m}";
          }
          {

            block = "sound";
          }
          {

            block = "time";
            interval = 60;
            format = "%a %d/%m %R";
          }
        ];
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."i3/status.toml".source = configFile;
  };
}
