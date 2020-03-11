{ config, lib, pkgs, ... }:

let
  updateInterval = "30m";
in
{

  systemd.services.nobbofin-autofetch = {
    description = "nobbofin: automatically process incoming e-mails";
    requires = [ "network.target" "network-online.target" ];
    after = [ "network.target" "network-online.target" ];

    script = ''
      set -efu

      cd $STATE_DIRECTORY
      
      if [ ! -d .ssh ]; then
        mkdir .ssh
        ssh-keygen -t ed25519 -f .ssh/id_ed25519 -P "" -C "nobbofin@$HOSTNAME"
        echo "THIS IS THE NEWLY CREATED SSH PUBLIC KEY:"
        cat .ssh/id_ed25519.pub
      fi

      if [ ! -d nobbofin ]; then
        git clone git@git.nerdworks.de:enno/nobbofin.git
      else
        git -C nobbofin pull
      fi

      cd nobbofin

      python3 fetch-mails.py \
        --host $MAIL_HOST \
        --user $MAIL_USER \
        --password $MAIL_PASSWORD \
        --imap-folder-prefix "INBOX." \
        --dry-run
      
      git add .
      git commit -m "nobbofin-autofetch: imported e-mails"
      git push
    '';

    path = with pkgs; [
      openssh
      git
      (
        python3.withPackages
          (
            pythonPackages: with pythonPackages; [
              weasyprint
            ]
          )
      )
    ];

    environment = {
      GIT_SSH_COMMAND = "ssh -i $STATE_DIRECTORY/.ssh/id_ed25519";
    };

    serviceConfig = {
      PrivateTmp = true;
      ProtectSystem = "full";
      ProtectHome = true;
      NoNewPrivileges = true;
      DynamicUser = true;
      StateDirectory = "nobbofin";
      Restart = "on-failure";
      RestartSec = 90;
      RuntimeMaxSec = "300";

      EnvironmentFile = "/run/keys/nobbofin.env";
      ReadOnlyPaths = "/run/keys/nobbofin.env";
    };
  };

  ptsd.secrets.files = {
    "nobbofin.env" = {};
  };

  systemd.timers.nobbofin-autofetch = {
    description = "Run nobbofin-autofetch every ${updateInterval}";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitInactiveSec = updateInterval;
      Unit = "nobbofin-autofetch.service";
    };
  };

}
