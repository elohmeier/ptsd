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
    ll = "exa -l";
    ls = "exa";
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
    mc
    ncdu
    ptsd-nnn
    ripgrep
    # telegram-sh
    tmux
    tree
    (writers.writePython3Bin "macos-fix-filefoldernames" { } ../4scripts/macos-fix-filefoldernames.py)
  ];

  # programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault true;
}
