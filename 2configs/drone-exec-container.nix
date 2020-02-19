{ config, lib, pkgs, ... }:

let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  ptsd.secrets.files = {
    "drone-ci.env" = {};
    "nwvpn-drone.key" = {
      owner = "systemd-network";
      group-name = "systemd-network";
      mode = "0440";
    };
  };

  containers.drone = {
    autoStart = true;
    enableTun = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.99";
    bindMounts = {
      "/run/keys" = {
        hostPath = "/run/keys";
        isReadOnly = true;
      };
      "/var/src/nixpkgs" = {
        hostPath = "/var/src/nixpkgs";
        isReadOnly = true;
      };
    };

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
          };

          ptsd.nwvpn = {
            enable = true;
            ip = universe.hosts."ws1-drone".nets.nwvpn.ip4.addr;
            keyname = "nwvpn-drone.key";
          };

          time.timeZone = "Europe/Berlin";

          i18n = {
            defaultLocale = "de_DE.UTF-8";
            supportedLocales = [ "de_DE.UTF-8/UTF-8" ];
          };

          systemd.services.drone-runner-exec = {
            description = "Drone Exec Runner";
            wantedBy = [ "multi-user.target" ];
            requires = [ "network.target" ];
            after = [ "network.target" "network-online.target" ];
            path = with pkgs; [ gitMinimal nix openssh ];
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
              EnvironmentFile = "/run/keys/drone-ci.env";
              ReadOnlyPaths = "/run/keys/drone-ci.env";
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
