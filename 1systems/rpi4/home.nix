{ config, lib, pkgs, ... }:

{
  imports = [
    #<ptsd/2configs/home/git.nix>
    #<ptsd/2configs/home/vim.nix>
    <ptsd/2configs/home/zsh.nix>

    <ptsd/2configs/home/baseX-minimal.nix>
    <ptsd/2configs/home/xsession-i3.nix>
  ];
}
