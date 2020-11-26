with import <ptsd/lib>;
{ config, pkgs, ... }:
let
  bridgeIfs = [
    "enp1s0"
    "enp2s0"
    "enp3s0"
  ];
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd>
    <ptsd/2configs>
    <ptsd/2configs/cli-tools.nix>
    <ptsd/2configs/nwhost.nix>
    <ptsd/2configs/prometheus/node.nix>
    <secrets-shared/nwsecrets.nix>
  ];

  ptsd.wireguard = {
    enableGlobalForwarding = true;
    networks.dlrgvpn = {
      enable = true;
      ip = universe.hosts."${config.networking.hostName}".nets.dlrgvpn.ip4.addr;
      natForwardIf = "br0"; # not sure if really needed (is it routing or NATing?), kept for backward compatibility
      client.allowedIPs = [ "192.168.178.0/24" ];
      routes = [
        { routeConfig = { Destination = "192.168.178.0/24"; }; }
      ];
    };
  };

  ptsd.nwbackup = {
    enable = true;
  };

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "apu2";
    bridges.br0.interfaces = bridgeIfs;
    interfaces.br0.useDHCP = true;
  };

  systemd.network.networks = builtins.listToAttrs (
    map
      (
        brName: {
          name = "40-${brName}";
          value = {
            networkConfig = {
              ConfigureWithoutCarrier = true;
            };
          };
        }
      )
      bridgeIfs
  );

  services.home-assistant = {
    enable = true;
    package = pkgs.nwhass;
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  networking.firewall.allowedTCPPortRanges = [{ from = 30000; to = 50000; }]; # for pyhomematic

  # TODO: prometheus-migrate
  # ptsd.nwtelegraf.inputs = {
  #   http_response = [
  #     {
  #       urls = [ "http://192.168.168.41:8123" ];
  #       response_string_match = "Home Assistant";
  #     }
  #   ];
  # };

  ptsd.nwmonit.extraConfig = [
    ''
      check host 192.168.168.41 with address 192.168.168.41
        if failed
          port 8123
          protocol http
          content = "Home Assistant"
        then alert
    ''
  ];

  services.nginx = {
    enable = true;

    commonHttpConfig = ''
      charset UTF-8;
      types_hash_max_size 4096;
      server_names_hash_bucket_size 128;
    '';

    virtualHosts = {
      "192.168.168.41" = {
        listen = [
          {
            addr = "192.168.168.41";
            port = 8123;
          }
        ];

        # proxy hass traffic
        # hass is configured to listen on 127.0.0.1:8123
        locations."/" = {
          extraConfig = ''
            proxy_pass http://127.0.0.1:8123;
          '';
        };
        locations."/api/websocket" = {
          extraConfig = ''
            proxy_pass http://127.0.0.1:8123;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
          '';
        };

        # proxy DLRG cloud to work around CSP iframe restrictions 
        # for calendar embedding
        locations."/apps" = {
          extraConfig = ''
            proxy_pass https://www.dlrg.cloud:443;
          '';
        };
        locations."/css" = {
          extraConfig = ''
            proxy_pass https://www.dlrg.cloud:443;
          '';
        };
        locations."/core" = {
          extraConfig = ''
            proxy_pass https://www.dlrg.cloud:443;
          '';
        };
        locations."/js" = {
          extraConfig = ''
            proxy_pass https://www.dlrg.cloud:443;
          '';
        };
        locations."/remote.php" = {
          extraConfig = ''
            proxy_pass https://www.dlrg.cloud:443;
          '';
        };
      };
    };
  };
}
