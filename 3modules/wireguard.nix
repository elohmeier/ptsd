{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.wireguard;
  enabledNetworks = filterAttrs (_: v: v.enable) cfg.networks;
  universe = import <ptsd/2configs/universe.nix>;

  generateSecret = _: netcfg: nameValuePair
    netcfg.keyname {
    owner = "systemd-network";
    mode = "0440";
    dependants = [ "systemd-networkd.service" ];
  };

  generateNetdev = _: netcfg: nameValuePair
    "10-${netcfg.ifname}" {
    netdevConfig = {
      Name = "${netcfg.ifname}";
      Kind = "wireguard";
      MTUBytes = "1300";
    };

    wireguardConfig = {
      PrivateKeyFile = config.ptsd.secrets.files."${netcfg.keyname}".path;
    };

    wireguardPeers = [
      {
        wireguardPeerConfig = {
          PublicKey = netcfg.publicKey;
          AllowedIPs = netcfg.allowedIPs;
          Endpoint = netcfg.endpoint;
          PersistentKeepalive = netcfg.persistentKeepalive;
        };
      }
    ];
  };

  generateNetwork = _: netcfg: nameValuePair
    "20-${netcfg.ifname}" {
    matchConfig = {
      Name = "${netcfg.ifname}";
    };
    address = [
      "${netcfg.ip}/${toString netcfg.subnetMask}"
    ];
  };
in
{
  options = {
    ptsd.wireguard = {
      networks = mkOption {
        type = types.attrsOf (
          types.submodule (
            { config, ... }: {
              options = {
                ifname = mkOption {
                  type = types.str;
                  default = config._module.args.name;
                };
                enable = mkEnableOption "${config.ifname}";
                ip = mkOption {
                  type = types.str;
                  example = "191.18.19.123";
                };
                subnetMask = mkOption {
                  type = types.int;
                  default = 24;
                  description = "CIDR notation";
                };
                publicKey = mkOption {
                  type = types.str;
                };
                allowedIPs = mkOption {
                  type = with types; listOf str;
                };
                endpoint = mkOption {
                  type = types.str;
                };
                persistentKeepalive = mkOption {
                  type = types.int;
                  default = 21;
                };
                keyname = mkOption {
                  type = types.str;
                  default = "${config.ifname}.key";
                };
              };
            }
          )
        );
        default = {};
      };
    };
  };

  config = mkIf (enabledNetworks != {}) {
    assertions =
      [
        {
          assertion = config.networking.useNetworkd;
          message = "ptsd.wireguard only supports systemd-networkd.";
        }
      ];

    environment.systemPackages = [ pkgs.wireguard ];
    boot.extraModulePackages = lib.optional (lib.versionOlder config.boot.kernelPackages.kernel.version "5.6") config.boot.kernelPackages.wireguard;

    ptsd.secrets.files = mapAttrs' generateSecret enabledNetworks;

    users.groups.keys.members = [ "systemd-network" ];

    systemd.network = {
      netdevs = mapAttrs' generateNetdev enabledNetworks;
      networks = mapAttrs' generateNetwork enabledNetworks;
    };

    # will query all wireguard interfaces by default
    ptsd.nwtelegraf.inputs.wireguard = [ {} ];
  };
}
