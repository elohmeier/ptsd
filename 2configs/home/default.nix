{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/zsh.nix>

    <ptsd/3modules/home>
  ];

  nixpkgs = {
    config.packageOverrides = import ../../5pkgs pkgs;
  };

  home.sessionVariables = {
    PASSWORD_STORE_DIR = "/home/enno/repos/password-store";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
