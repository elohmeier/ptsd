{ config, lib, pkgs, ... }:

with lib;
let
  universe = import ../common/universe.nix;
in
{
  console.keyMap = mkDefault "de-latin1";

  environment = {
    systemPackages = with pkgs; [
      btop
      ncdu_1
      tmux
      vim
    ];
  };

  boot.tmpOnTmpfs = mkDefault true;

  nix.gc = {
    automatic = mkDefault true;
    options = "-d";
  };

  services.timesyncd = {
    enable = mkDefault true;
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
    enable = mkDefault (hasAttr "nwvpn" universe.hosts."${config.networking.hostName}".nets);
    ip = universe.hosts."${config.networking.hostName}".nets.nwvpn.ip4.addr;
  };

  ptsd.tailscale.enable = mkDefault true;

  services.openssh.hostKeys = mkIf config.ptsd.secrets.enable [
    {
      # configure path explicitely to have correct configuration
      # when built under /mnt (e.g. in installer-situation)
      # path = (toString <secrets/ssh.id_ed25519>);
      path = "/var/src/secrets/ssh.id_ed25519";
      type = "ed25519";
    }
  ];

  programs.fish.enable = mkDefault true;
  users.defaultUserShell = pkgs.fish;
  ptsd.secrets.files."ssh.id_ed25519.pub".mode = "0444";
  environment.variables = { EDITOR = "vim"; };
}
