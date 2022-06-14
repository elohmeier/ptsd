{ config, lib, pkgs, ... }:

let
  logseq-sync-git = pkgs.writeShellScriptBin "logseq-sync-git" ''
    set -e
    REPO=/home/enno/repos/logseq
    export GIT_SSH_COMMAND="ssh -i /home/enno/.ssh/id_ed25519"
    ${pkgs.git}/bin/git -C "$REPO" pull --rebase=merges
    ${pkgs.git}/bin/git -C "$REPO" push origin main
  '';
in
{
  home.packages = [ logseq-sync-git ];

  systemd.user.services.logseq-sync-git = {
    Unit.Description = "Sync Logseq git repo";
    Service = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = "${logseq-sync-git}/bin/logseq-sync-git";
    };
  };

  systemd.user.timers.logseq-sync-git = {
    Unit.Description = "Sync Logseq git repo periodically";
    Timer = {
      OnBootSec = "1min";
      OnUnitInactiveSec = "1min";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
