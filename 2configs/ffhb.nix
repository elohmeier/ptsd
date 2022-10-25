{ config, lib, pkgs, ... }:

let
  fastdConfig = pkgs.writeText "fastd.conf" ''
    bind 127.0.0.1:10000;
    secret "";
    method "salsa2012+gmac";
  '';

  peerCfg = host: key: pkgs.writeText "fastd-peer-${host}.conf" ''
    key "${key}";
    remote ipv4 "${host}.bremen.freifunk.net" port 50000;
    remote ipv4 "${host}.ffhb.de" port 50000;
  '';
in
{
  systemd.services.fastd-ffhb = {
    description = "fastd tunneling daemon for Freifunk Bremen";
    # wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    script = ''
      ${pkgs.fastd}/bin/fastd \
        --log-level verbose \
        --interface ffhb \
        --mode tap \
        --mtu 1280 \
        --config ${fastdConfig} \
        --config-peer ${peerCfg "vpn07" "68220e494e7a415d5dd97b5aa7a0d82088ed971f468ff16bcfd08fe0d4d6449f"} \
        --config-peer ${peerCfg "vpn08" "8a2cee2fa56fb32e356ad08d6a2578978d45b2f6263a3e252b3dbde1fde27604"} \
        --config-peer ${peerCfg "vpn09" "8bba84d8d4dec2ad08156c5507f1af083b0a0fc608f9a87df8f71d5b55dcc980"} \
        --config-peer ${peerCfg "vpn10" "7bbbf7ad0796f5830ffe25394134d12979dea360750fac18678eec49d108fb80"} \
        --on-up '${pkgs.iproute}/bin/ip link set ffhb up'
    '';

    serviceConfig = {
      DynamicUser = true;
      AmbientCapabilities = "CAP_NET_ADMIN";
      CapabilityBoundingSet = "CAP_NET_ADMIN";
    };
  };

  environment.systemPackages = with pkgs; [
    alfred
    batctl
    fastd
  ];

  systemd.network = {
    netdevs.br0.netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
    networks.br0 = {
      matchConfig.Name = "br0";
      networkConfig.DHCP = "yes";
    };
  };
}
