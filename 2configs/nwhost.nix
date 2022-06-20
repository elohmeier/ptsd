{ config, lib, pkgs, ... }:
let
  universe = import ./universe.nix;
in
{
  imports = [
    ../3modules
    ./nwhost-mini.nix
  ];

  programs.fish.shellAliases = {
    l = "exa -al";
    la = "exa -al";
    lg = "exa -al --git";
    ll = "exa -l";
    ls = "exa";
    tree = "exa --tree";
  };

  environment.systemPackages = with pkgs; [
    bottom
    btop
    checkSSLCert
    cryptsetup
    dnsutils
    exa
    fd
    git
    macos-fix-filefoldernames
    mc
    ncdu
    ptsd-nnn
    ripgrep
    tmux
  ];

  # programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault config.networking.firewall.enable;
}
