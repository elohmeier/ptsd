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

  nix.gc = {
    automatic = true;
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

  networking.domain = "host.nerdworks.de";

  networking.hosts = {
    "127.0.0.1" = [ "${config.networking.hostName}.${config.networking.domain}" "${config.networking.hostName}" ];
    "::1" = [ "${config.networking.hostName}.${config.networking.domain}" "${config.networking.hostName}" ];
  };

  ptsd.nwvpn = {
    enable = true;
    ip = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
  };

  services.openssh.hostKeys = [
    {
      path = (toString <secrets/ssh.id_ed25519>);
      type = "ed25519";
    }
  ];

  #ptsd.nwbackup = {
  #  enable = true;
  #};
}
