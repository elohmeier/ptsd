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
    telegram-sh
    dnsutils
    cryptsetup
    ncdu
    tmux
  ];

  programs.mosh.enable = lib.mkDefault true;
  services.fail2ban.enable = lib.mkDefault true;
}
