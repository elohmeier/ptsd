with import <ptsd/lib>;
{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>

    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost.nix>

    <ptsd/2configs/backup-host.nix>

    <secrets/wifi.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  networking.hostName = "eee1";

  networking = {
    nameservers = [ "8.8.8.8" "8.8.4.4" ]; # local DNS infrastructure returns malformed packets
  };

  networking.wireless.enable =
    true; # Enables wireless support via wpa_supplicant.

  services.logind.lidSwitch = "ignore";

  services.cron = {
    enable = true;
    systemCronJobs = [
      # reboot every sunday at 6 am
      "0 6 * * 0      root    ${pkgs.systemd}/bin/reboot"
    ];
  };
}
