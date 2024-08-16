{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.ptsd.fastd;

  peerCfg =
    peer:
    pkgs.writeText "fast-peer-${peer.hostname}.conf" ''
      key "${peer.publickey}";
      remote ipv4 "${peer.hostname}" port ${toString peer.port};
      float yes;
    '';
in
{
  options.ptsd.fastd = {
    enable = mkEnableOption "ptsd.fastd";
    networks = mkOption {
      type = types.attrsOf (
        types.submodule (
          { config, ... }:
          {
            options = {
              name = mkOption {
                type = types.str;
                default = config._module.args.name;
              };
              mtu = mkOption { type = types.int; };
              peers = mkOption {
                type = types.listOf (
                  types.submodule (_: {
                    options = {
                      hostname = mkOption { type = types.str; };
                      port = mkOption { type = types.int; };
                      publickey = mkOption { type = types.str; };
                    };
                  })
                );
              };
            };
          }
        )
      );
    };
  };

  config = mkIf cfg.enable {
    systemd.services = mapAttrs' (
      name: cfg:
      nameValuePair "fastd-${name}" {
        description = "fastd tunneling daemon for ${name}";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        script = ''
          mkdir -p /run/fastd
          rm -f "/run/fastd/${name}.sock"
          chown nobody:nogroup /run/fastd

          SECRET_FILE=/var/lib/fastd/${name}.secret
          if [ ! -f "$SECRET_FILE" ]; then
            echo "Creating new secret file $SECRET_FILE"
            ${pkgs.fastd}/bin/fastd --generate-key > "$SECRET_FILE"
            echo secret \"$(grep Secret "$SECRET_FILE" | cut -d " " -f2)\"\; > /var/lib/fastd/${name}.conf
          fi

          exec ${pkgs.fastd}/bin/fastd \
            --status-socket "/run/fastd/${name}.sock" \
            --user nobody \
            --group nogroup \
            --log-level verbose \
            --mode tap \
            --interface "fastd-${name}" \
            --mtu 1280 \
            --bind 0.0.0.0:10000 \
            --method salsa2012+umac \
            --on-up '${pkgs.iproute}/bin/ip link set "fastd-${name}" up; ${pkgs.batctl}/bin/batctl -m "bat-${name}" if add "fastd-${name}"' \
            --on-verify "true" \
            --config "/var/lib/fastd/${name}.conf" \
            ${concatStringsSep " " (map (peer: "--config-peer \"${peerCfg peer}\"") cfg.peers)}
        '';

        serviceConfig.StateDirectory = "fastd";
      }
    ) cfg.networks;

    networking.firewall.allowedUDPPorts = [ 10000 ];

    environment.systemPackages = with pkgs; [
      batctl
      fastd
    ];

    # example network config:
    # systemd.network = {
    #   networks.bat = {
    #     dhcpV4Config = {
    #       RouteMetric = 2000; # higher than the default route
    #       # UseRoutes = false;
    #     };
    #     linkConfig.RequiredForOnline = "no";
    #     matchConfig.Kind = "batadv";
    #     networkConfig.DHCP = "yes";
    #   };
    # };
  };
}
