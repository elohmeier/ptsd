with import <ptsd/lib>;
{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/stateless-root.nix>
    <ptsd/2configs/themes/fraam.nix>

    <ptsd/2configs/prometheus/node.nix>

    <secrets-shared/nwsecrets.nix>

    <home-manager/nixos>
  ];

  home-manager = {
    users.mainUser = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  networking = {
    hostName = "ws2";
    useNetworkd = true;
    useDHCP = false;

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      wifi = {
        backend = "iwd";
        macAddress = "random";
        powersave = true;
      };
    };

    wireless.iwd.enable = true;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ptsd.cli = {
    enable = true;
    fish.enable = true;
    defaultShell = "fish";
  };

  ptsd.desktop = {
    enable = true;
    profiles = [
      "3dprinting"
      "admin"
      "dev"
      "kvm"
      "media"
      "office"
    ];
  };

  ptsd.nwacme.hostCert.enable = false;
}
