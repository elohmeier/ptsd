{ config, lib, pkgs, ... }:
let
  hostconfig = config;
  universe = import <ptsd/2configs/universe.nix>;
in
{
  ptsd.secrets.files = {
    "drone-ci.env" = {
      path = "/run/drone-runner-exec/drone-ci.env";
      #dependants = [ "container@drone.service" ];
    };
    "nwvpn-drone.key" = {
      owner = "systemd-network";
      mode = "0440";
      #dependants = [ "container@drone.service" ];
    };
  };

  containers.drone = {
    autoStart = true;
    hostBridge = "br0";
    privateNetwork = true;
    enableTun = true;
    bindMounts = {

      "/run/drone-runner-exec" = {
        hostPath = "/run/drone-runner-exec";
        isReadOnly = false;
      };

      # required for nwvpn
      "/run/keys" = {
        hostPath = "/run/keys";
        isReadOnly = true;
      };

      "/var/src/nixpkgs" = {
        hostPath = "/var/src/nixpkgs";
        isReadOnly = true;
      };

      # "/var/src/nixpkgs-unstable" = {
      #   hostPath = "/var/src/nixpkgs-unstable";
      #   isReadOnly = true;
      # };

    };
    ephemeral = true;

    config =
      { config, pkgs, ... }:
      {
        imports = [
          <ptsd>
          <ptsd/2configs>
        ];

        boot.isContainer = true;

        networking = {
          useHostResolvConf = false;
          nameservers = [ "8.8.8.8" "8.8.4.4" ];
          useNetworkd = true;
          interfaces.eth0.useDHCP = true;
        };

        ptsd.wireguard.networks.nwvpn = {
          enable = true;
          ip = universe.hosts."${hostconfig.networking.hostName}-drone".nets.nwvpn.ip4.addr;
          keyname = "nwvpn-drone.key";
        };

        time.timeZone = "Europe/Berlin";

        i18n = {
          defaultLocale = "de_DE.UTF-8";
          supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
        };

        virtualisation.docker.enable = true;

        systemd.services.drone-runner-exec = {
          description = "Drone Exec Runner";
          wantedBy = [ "multi-user.target" ];
          requires = [ "network.target" ];
          after = [ "network.target" "network-online.target" ];
          path = with pkgs; [ gitMinimal nix openssh docker drone-gitea-release drone-telegram ];
          serviceConfig = {
            ExecStart = "${pkgs.drone-runner-exec}/bin/drone-runner-exec";
            StartLimitInterval = 86400;
            StartLimitBurst = 5;
            NoNewPrivileges = true;
            LimitNPROC = 256;
            LimitNOFILE = 104857600;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectHome = true;
            ProtectSystem = "full";
            DynamicUser = true;
            Restart = "on-failure";
            EnvironmentFile = "/run/drone-runner-exec/drone-ci.env";
            RuntimeDirectory = "drone-runner-exec";
            SupplementaryGroups = "docker";
          };
          environment = {
            DRONE_RPC_HOST = "ci.nerdworks.de";
            DRONE_RPC_PROTO = "https";
            DRONE_RUNNER_CAPACITY = "8";
            DRONE_MEMORY_LIMIT = "4294967296";
            #DRONE_RPC_SECRET = ""; # set via drone-ci.env
          };
        };
      };
  };
}
