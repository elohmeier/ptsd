{ config, lib, pkgs, ... }:

{
  ptsd.secrets.files."drone-ci.env" = {};

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
              LimitNPROC = 64;
              LimitNOFILE = 1048576;
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
