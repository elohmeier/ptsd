{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/home/git.nix>
    <ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/tmux.nix>
    <ptsd/2configs/home/zsh.nix>

    <ptsd/3modules/home>
  ];
}
