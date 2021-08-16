{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.neovim;
in
{
  options = {
    ptsd.neovim = {
      enable = mkEnableOption "neovim";
      package = mkOption {
        type = types.package;
        default = pkgs.ptsd-neovim-small;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.variables.EDITOR = "nvim";

    environment.systemPackages = [
      cfg.package
    ];
  };
}
