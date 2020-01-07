{ config, lib, pkgs, ... }:

let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/3modules>
    <ptsd/2configs/nwhost-mini.nix>
  ];

  ptsd.lego = {
    enable = true;
    domain = "${config.networking.hostName}.${config.networking.domain}";
  };

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
  ];

  programs.mosh.enable = true;
  services.fail2ban.enable = true;
}
