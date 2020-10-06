{ config, lib, pkgs, ... }:
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/3modules>
    <ptsd/2configs/acme-nwhost-cert.nix>
    <ptsd/2configs/nwhost-mini.nix>
  ];

  ptsd.nwtelegraf.enable = true;

  ptsd.nwmonit = {
    enable = true;
  };

  ptsd.nwbackup = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs."telegram.sh"
    pkgs.dnsutils
    pkgs.cryptsetup
    pkgs.tmux
  ];

  programs.mosh.enable = true;
  services.fail2ban.enable = true;

  system.fsPackages = [ pkgs.ntfs3g ];
}
