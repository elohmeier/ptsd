{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.cli;
in
{
  options = {
    ptsd.cli = {
      enable = mkEnableOption "cli";
      defaultShell = mkOption {
        type = types.strMatching "zsh|fish";
        default = "zsh";
      };
      users = mkOption {
        type = with types; listOf str;
        default = [ "root" "mainUser" ];
      };
      fish.enable = mkOption {
        type = types.bool;
        default = false;
      };
      zsh.enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  imports = [
    <home-manager/nixos>
  ];

  config = mkIf cfg.enable {

    programs.fish.enable = cfg.defaultShell == "fish";

    # Make sure zsh lands in /etc/shells
    # to not be affected by user not showing up in LightDM
    # as in https://discourse.nixos.org/t/normal-users-not-appearing-in-login-manager-lists/4619
    programs.zsh.enable = cfg.defaultShell == "zsh";

    users.defaultUserShell = { "zsh" = pkgs.zsh; "fish" = pkgs.fish; }."${cfg.defaultShell}";

    # as recommended in
    # https://github.com/rycee/home-manager/blob/master/modules/programs/zsh.nix
    environment.pathsToLink = mkIf (cfg.defaultShell == "zsh") [ "/share/zsh" ];

    home-manager.users = (listToAttrs (map
      (
        user: {
          name = user;
          value = { pkgs, ... }: {
            programs = {

              fish = mkIf cfg.fish.enable {
                enable = true;
                shellAliases = (import ../2configs/aliases.nix).aliases;
                shellAbbrs = (import ../2configs/aliases.nix).abbreviations;
              };

              zsh = mkIf cfg.zsh.enable {
                enable = true;
              };
            };
          };
        }
      )
      cfg.users
    ));
  };
}
