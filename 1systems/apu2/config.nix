{ config, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/minimal.nix
    ../../2configs/prometheus-node.nix

    ./modules/home-assistant.nix
    ./modules/networking.nix
    ./modules/nginx.nix
  ];

  ptsd.nwbackup = {
    enable = true;
    paths = [
      "/var/lib/acme"
      "/var/lib/hass"
      "/var/lib/private/mosquitto"
      "/var/src"
    ];
    exclude = [
      "/var/lib/hass/home-assistant_v2.db*" # save data volume
    ];
  };

  environment.systemPackages = with pkgs; [ htop vim tcpdump ];

  ptsd.secrets.files = {
    "nwbackup.id_ed25519" = {
      path = "/root/.ssh/id_ed25519";
    };
  };

  system.stateVersion = "21.11";
}
