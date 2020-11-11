{ config, lib, pkgs, ... }:
{
  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/zsh.nix>
  ];

  home.packages = with pkgs; [
    unrar
  ];

  nixpkgs.config.allowUnfree = true; # required for unrar
}
