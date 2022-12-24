{ config, lib, pkgs, ... }:

let
  interface = "ffhh";

  fastdConfig = pkgs.writeText "fastd.conf" ''
    secret "";
  '';

  peerCfg = host: key: pkgs.writeText "fastd-peer-${host}.conf" ''
    key "${key}";
    remote ipv4 "${host}-new.hamburg.freifunk.net" port 10007;
    float yes;
  '';
in
{
  systemd.services."fastd-${interface}" = {
    description = "fastd tunneling daemon for Freifunk";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    script = ''
      mkdir -p /run/fastd
      rm -f "/run/fastd/${interface}.sock"
      chown nobody:nogroup /run/fastd

      exec ${pkgs.fastd}/bin/fastd \
        --status-socket "/run/fastd/${interface}.sock" \
        --user nobody \
        --group nogroup \
        --log-level verbose \
        --mode tap \
        --interface "${interface}" \
        --mtu 1312 \
        --bind 0.0.0.0:10000 \
        --method salsa2012+umac \
        --on-up '${pkgs.iproute}/bin/ip link set "${interface}" up; ${pkgs.batctl}/bin/batctl if add "${interface}"' \
        --on-verify "true" \
        --config ${fastdConfig} \
        --config-peer ${peerCfg "gw03" "e15295b86138ac490d611e4100f847ccfb7052d5091ded4659f25940be2c0546"}
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ 5291 69 ];
    allowedUDPPorts = [ 69 ];
    trustedInterfaces = [ interface "bat0" ];
  };

  environment.systemPackages = with pkgs; [
    batctl
    fastd
  ];

  systemd.network = {
    networks.bat0 = {
      matchConfig.Name = "bat0";
      networkConfig.DHCP = "yes";
      dhcpV4Config.RouteMetric = 2000; # higher than the default route
    };
  };
}
