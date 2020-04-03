{ config, pkgs, ... }: {
  services.tor = {
    enable = true;
    client.enable = true;
    hiddenServices.ssh.map = [
      { port = 22; }
    ];
  };

  systemd.services.tor-ssh-announce = {
    description = "Announce hidden ssh in Telegram";
    after = [ "tor.service" "network.target" "network-online.target" "systemd-resolved.service" ];
    requires = [ "tor.service" "network.target" "network-online.target" ];
    wants = [ "systemd-resolved.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart =
        let
          hsfile = "/var/lib/tor/onion/ssh/hostname";
        in
          pkgs.writeDash "telegram-announce-ssh" ''
            set -efu
            until test -e ${hsfile}; do
              echo "waiting for ${hsfile}"
              sleep 1
            done
            ${pkgs."telegram.sh"}/bin/telegram "SSH Hidden Service for ${config.networking.hostName} at $(cat ${hsfile})"
          '';
      PrivateTmp = true;
      User = "tor";
      Type = "oneshot";

      Restart = "on-failure";
      RestartSec = "2min";
    };
  };
}
