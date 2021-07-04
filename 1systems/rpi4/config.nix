{ config, pkgs, ... }:
let
  universe = import ../../2configs/universe.nix;
  tinypilot = pkgs.python3Packages.callPackage ../5pkgs/tinypilot { };
in
{
  imports = [
    ../..
    ../../2configs
    ../../2configs/nwhost-mini.nix

    ../../2configs/prometheus/node.nix

    <secrets/wifi.nix>

    # ../../2configs/bluetooth.nix
    ../../2configs/baseX.nix


    ../../2configs/zsh-enable.nix
  ];

  services.resolved = {
    enable = true;
    dnssec = "false";
  };

  home-manager = {
    users.mainUser = { pkgs, ... }:
      {
        imports = [
          ../../2configs/home
          ../../2configs/home/xsession-i3.nix
        ];
      };
  };

  nix = {
    #    buildMachines = [
    #      {
    #        hostName = universe.hosts.ws1.nets.bs53lan.ip4.addr;
    #        sshUser = "enno";
    #        sshKey = "/tmp/id_ed25519";
    #        systems = [ "x86_64-linux" "aarch64-linux" ];
    #        maxJobs = 48;
    #      }
    #    ];
    trustedUsers = [ "root" "enno" ];
    #    distributedBuilds = true;
    #    extraOptions = ''
    #      builders-use-substitutes = true
    #    '';
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "rpi4";
    interfaces.eth0.useDHCP = true;
    interfaces.wlan0.useDHCP = true;

    firewall.allowedTCPPorts = [ 8000 8080 ];

    # wpa_supplicant
    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
    };
  };

  # allow hot-plug
  systemd.network.networks."40-eth0".networkConfig.ConfigureWithoutCarrier = true;

  # systemd.services.tinypilot = {
  #   description = "TinyPilot";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "networking.target" ];
  #   environment = {
  #     CORS_ORIGIN = "http://192.168.178.89:8000";
  #     USE_RELOADER = "0";
  #   };
  #   serviceConfig = {
  #     ExecStart = "${tinypilot}/bin/tinypilot";
  #     DynamicUser = true;
  #     Restart = "on-failure";
  #     PrivateTmp = "true";
  #     ProtectSystem = "full";
  #     ProtectHome = "true";
  #     NoNewPrivileges = "true";
  #   };
  # };

  # systemd.services.ustreamer = {
  #   description = "uStreamer";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "networking.target" ];
  #   serviceConfig = {
  #     #ExecStart = "${pkgs.ustreamer}/bin/ustreamer --host 0.0.0.0 --port 8080 --resolution 1920x1080 --format=uyvy --persistent --dv-timings --drop-same-frames=30";
  #     ExecStart = "${pkgs.ustreamer}/bin/ustreamer --host 0.0.0.0 --port 8080 --resolution 1920x1080";
  #     DynamicUser = true;
  #     Restart = "on-failure";
  #     PrivateTmp = "true";
  #     ProtectSystem = "full";
  #     ProtectHome = "true";
  #     NoNewPrivileges = "true";
  #     SupplementaryGroups = "video";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    # ustreamer

    htop
    mc
    ncdu
    # nnn
    tmux
    tree
    unzip
    wget
  ];



}
