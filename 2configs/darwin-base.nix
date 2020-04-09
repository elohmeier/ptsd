{ config, pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  users.users.enno = {
    createHome = true;
    description = "Enno Lohmeier";
    home = "/Users/enno";
    isHidden = false;
    shell = "${pkgs.zsh}/bin/zsh";
  };

  programs.tmux.enable = true;
  programs.zsh.enable = true;
}
