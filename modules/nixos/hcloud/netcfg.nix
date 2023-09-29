{ config, lib, pkgs, ... }:

let
  cfg = config.services.hcloud-netcfg;
  hcloud-netcfg = pkgs.python3Packages.buildPythonApplication {
    pname = "hcloud-netcfg";
    version = "0.1.0";
    src = ./netcfg;
    propagatedBuildInputs = with pkgs.python3Packages; [ requests pyyaml ];
  };
in
{
  options.services.hcloud-netcfg = {
    enable = lib.mkEnableOption "Configure network interface for Hetzner Cloud";
    withoutIPv6DNS = lib.mkEnableOption "Configure network interface for Hetzner Cloud without DNS for IPv6";
  };

  config = lib.mkIf cfg.enable {

    networking.hostName = ""; # set by hcloud-netcfg

    systemd.services.hcloud-netcfg = {
      description = "Configure network interface for Hetzner Cloud";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script =
        ''
          metadata=$(mktemp)
          private_networks=$(mktemp)
          trap "rm -f $metadata $private_networks" EXIT

          ${pkgs.curl}/bin/curl -o $metadata http://169.254.169.254/hetzner/v1/metadata > /dev/null 2>&1
          echo "Metadata written to $metadata"

          ${pkgs.curl}/bin/curl -o $private_networks http://169.254.169.254/hetzner/v1/metadata/private-networks > /dev/null 2>&1
          echo "Private networks written to $private_networks"

          ${hcloud-netcfg}/bin/netcfg -m $metadata -p $private_networks env > /etc/hcloud.env

          rm /etc/hostname || true
          ${hcloud-netcfg}/bin/netcfg -m $metadata -p $private_networks hostname > /etc/hostname
          echo "Hostname written to /etc/hostname"

          ${pkgs.nettools}/bin/hostname -F /etc/hostname
          echo "Hostname set to $(${pkgs.nettools}/bin/hostname)"

          ${hcloud-netcfg}/bin/netcfg -m $metadata -p $private_networks ${lib.optionalString cfg.withoutIPv6DNS "--no-ipv6-dns"} network > /etc/systemd/network/50-hcloud.network
          echo "Network configuration written to /etc/systemd/network/50-hcloud.network"
          networkctl reload
        '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
