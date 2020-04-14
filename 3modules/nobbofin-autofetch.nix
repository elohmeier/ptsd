{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.ptsd.nobbofin-autofetch;
in
{
  options = {
    ptsd.nobbofin-autofetch = {
      enable = mkEnableOption "nobbofin-autofetch";
      updateInterval = mkOption {
        default = "30m";
        example = "1h";
        type = types.str;
        description = "When to perform a <command>nobbofin-autofetch</command> run (git pull). See <command>man 7 systemd.time</command> for the format.";
      };
    };
  };

  config = mkIf cfg.enable {

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
          --imap-folder-prefix "INBOX."
      
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
      description = "Run nobbofin-autofetch every ${cfg.updateInterval}";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2m";
        OnUnitInactiveSec = cfg.updateInterval;
        Unit = "nobbofin-autofetch.service";
      };
    };

  };
}
