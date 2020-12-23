{ config, lib, pkgs, ... }:

with import <ptsd/lib>;
let
  universe = import <ptsd/2configs/universe.nix>;
in
{
  imports = [
    <ptsd/3modules>
    <ptsd/2configs/tor-ssh.nix>
  ];

  boot.tmpOnTmpfs = true;

  nix.gc = {
    automatic = lib.mkDefault true;
    options = "-d";
  };

  services.timesyncd = {
    enable = true;
    servers = [
      "0.de.pool.ntp.org"
      "1.de.pool.ntp.org"
      "2.de.pool.ntp.org"
      "3.de.pool.ntp.org"
    ];
  };

  networking.domain = if hasAttr "domain" universe.hosts."${config.networking.hostName}" then universe.hosts."${config.networking.hostName}".domain else "host.nerdworks.de";

  networking.hosts = {
    "127.0.0.1" = [ "${config.networking.hostName}.${config.networking.domain}" "${config.networking.hostName}" ];
    "::1" = [ "${config.networking.hostName}.${config.networking.domain}" "${config.networking.hostName}" ];
  };

  ptsd.wireguard.networks.nwvpn = {
    enable = lib.mkDefault (hasAttr "nwvpn" universe.hosts."${config.networking.hostName}".nets);
    ip = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
  };

  services.openssh.hostKeys = [
    {
      # configure path explicitely to have correct configuration
      # when built under /mnt (e.g. in installer-situation)
      # path = (toString <secrets/ssh.id_ed25519>);
      path = "/var/src/secrets/ssh.id_ed25519";
      type = "ed25519";
    }
  ];

  users.groups.certs = { };
  ptsd.nwtraefik.groups = "certs";

  #ptsd.nwbackup = {
  #  enable = true;
  #};
}
