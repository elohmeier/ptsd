{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.tor-ssh;
in
{
  options = {
    ptsd.tor-ssh = {
      enable = mkEnableOption "ptsd.tor-ssh";
    };
  };

  config = mkIf cfg.enable {

    services.tor = {
      enable = true;
      client = {
        enable = true;
      };
      relay.onionServices.ssh.map = [
        { port = 22; }
      ];
    };
    services.privoxy.enable = lib.mkForce false;

    ptsd.secrets.files."tor-ssh-announce.env" = {
      dependants = [ "tor-ssh-announce.service" ];
      source-path = "/var/src/secrets-shared/tor-ssh-announce.env";
    };

    systemd.services.tor-ssh-announce = {
      description = "Announce hidden ssh in Telegram";
      after = [ "tor.service" "network.target" "network-online.target" "systemd-resolved.service" ];
      requires = [ "tor.service" "network.target" "network-online.target" ];
      wants = [ "systemd-resolved.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = config.ptsd.secrets.files."tor-ssh-announce.env".path;
        ExecStart =
          let
            hsfile = "/var/lib/tor/onion/ssh/hostname";
          in
          pkgs.writers.writeDash "telegram-announce-ssh" ''
            set -efu
            until test -e ${hsfile}; do
              echo "waiting for ${hsfile}"
              sleep 1
            done
            sleep 10
            ${pkgs.telegram-sh}/bin/telegram "SSH Hidden Service for ${config.networking.hostName} at $(cat ${hsfile})"
          '';
        PrivateTmp = true;
        User = "tor";
        Type = "oneshot";

        Restart = "on-failure";
        RestartSec = "2min";
      };
    };
  };
}
