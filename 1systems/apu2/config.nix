{ config, pkgs, ... }:

{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix
    ../../2configs/profiles/minimal.nix
    ../../2configs/prometheus/node.nix

    ./modules/hass.nix
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
  ptsd.neovim.enable = false;

  # TODO: prometheus-migrate
  # ptsd.nwtelegraf.inputs = {
  #   http_response = [
  #     {
  #       urls = [ "http://192.168.168.41:8123" ];
  #       response_string_match = "Home Assistant";
  #     }
  #   ];
  # };

  #ptsd.nwmonit.extraConfig = [
  #  ''
  #    check host 192.168.168.41 with address 192.168.168.41
  #      if failed
  #        port 8123
  #        protocol http
  #        content = "Home Assistant"
  #      then alert
  #  ''
  #];

  ptsd.secrets.files = {
    "nwbackup.id_ed25519" = {
      path = "/root/.ssh/id_ed25519";
    };
  };
}
