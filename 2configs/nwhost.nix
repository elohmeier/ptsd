{ config, lib, pkgs, ... }:
let
  universe = import ./universe.nix;
in
{
  imports = [
    ../3modules
    ./nwhost-mini.nix
  ];

  ptsd.nwacme = {
    enable = lib.mkDefault true;
    hostCert.enable = lib.mkDefault true;
  };

  ptsd.nwbackup = {
    enable = lib.mkDefault true;
  };

  environment.systemPackages = with pkgs; [
    bottom
    btop
    checkSSLCert
    cryptsetup
    dnsutils
    exa
    fd
    mc
    ncdu
    ptsd-nnn
    ripgrep
    # telegram-sh
    tmux
    tree
    (writers.writePython3Bin "macos-fix-filefoldernames" { } ../4scripts/macos-fix-filefoldernames.py)
  ];

  programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault true;
}
