with import <ptsd/lib>;
{ config, lib, pkgs, ... }:

{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/nwhost-mini.nix>
    <ptsd/2configs/prometheus/node.nix>

    <secrets/wifi.nix>
    <secrets-shared/nwsecrets.nix>

    #<ptsd/2configs/octoprint-klipper-ender3.nix>

    <home-manager/nixos>
    <ptsd/2configs/zsh-enable.nix>
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    curaengine_stable = pkgs.curaengine_stable.overrideAttrs (oldAttrs: rec {
      # TODO: remove when https://github.com/NixOS/nixpkgs/pull/115181 is merged
      postPatch = ''
        sed -i 's,--static,,g' Makefile
        ${lib.optionalString pkgs.stdenv.isi686 "sed -i 's,-flto,,g' -i Makefile"}
      '';
    });

    # klipper = pkgs.klipper.overrideAttrs(oldAttrs: rec {
    #   postPatch = ''
    #     sed -i 's/-flto //' chelper/__init__.py
    #     sed -i 's/import os, logging/import os, logging; logging.basicConfig(level=logging.DEBUG)/' chelper/__init__.py
    #   '';
    # });
  };

  #environment.systemPackages = [ (pkgs.v4l-utils.override { withGUI = false; }) ];

  ptsd.mjpg-streamer = {
    enable = false;
    inputPlugin = "input_uvc.so -f 15 -r 640x480"; # physical resolution: 1280x1024 (1.3 MP)
    outputPlugin = "output_http.so -w @www@ -n -p ${toString config.ptsd.nwtraefik.ports.mjpg-streamer}";
  };

  home-manager = {
    users.mainUser = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
    users.root = { ... }:
      {
        imports = [
          ./home.nix
        ];
      };
  };

  networking = {
    hostName = "eee1";
    useNetworkd = true;
    useDHCP = false;
    interfaces.enp4s0.useDHCP = true;
    interfaces.wlp1s0.useDHCP = true;
    wireless.enable = true;
  };

  systemd.network.networks = {
    "40-enp4s0" = {
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };
  };

  services.logind.lidSwitch = "ignore";

  ptsd.desktop = {
    enable = true;
    audio.enable = false;
    bluetooth.enable = false;
    qt.enable = false;
    profiles = [
    ];
    terminalConfig = "termite";
    numlockAuto = false;
  };

}
