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

  ptsd.desktop = {
    enable = true;
    waybar.co2 = true;
    # nvidia.enable = true; # todo: replace writeNu in desktop module
    #autolock.enable = false;
    baresip = {
      enable = true;
    };
    fontSize = 18.0;
    waybar.primaryOutput = "Dell Inc. DELL P2415Q D8VXF96K09HB";
  };

  home-manager.users.mainUser = { pkgs, ... }: {
    wayland.windowManager.sway.config.output = {
      "Goldstar Company Ltd LG UltraFine 701NTAB7S144" = {
        pos = "4320 0";
        transform = "270";
        mode = "4096x2304@59.999Hz";
        scale = "1";
        bg = "/mnt/photos/photos/originals/eosr6/2022/2022-04/2022-04-12/JI2A8211.JPG fill";
        #bg = "/mnt/photos/photos/originals/eosr6/2022/2022-04/2022-04-06/JI2A7930.JPG fill"; # not rotated
      };
      "Dell Inc. DELL P2415Q D8VXF96K09HB" = {
        pos = "0 130";
        transform = "90";
        mode = "3840x2160@59.997Hz";
        scale = "1";
        bg = "/mnt/photos/photos/originals/eosr6/2022/2022-04/2022-04-12/JI2A8211.JPG fill";
      };
      "Dell Inc. DELL P2415Q D8VXF64G0LGL" = {
        pos = "2160 130";
        transform = "90";
        mode = "3840x2160@59.997Hz";
        scale = "1";
        bg = "/mnt/photos/photos/originals/eosr6/2022/2022-04/2022-04-12/JI2A8211.JPG fill";
        #bg = "/mnt/photos/photos/originals/eosr6/2022/2022-04/2022-04-01/JI2A7676.JPG fill"; # not rotated
      };
    };

    home.packages = [ logseq-sync-git ];

    programs.ssh.matchBlocks."git.nerdworks.de" = {
      hostname = "git.nerdworks.de";
      identityFile = "/home/enno/.ssh/id_ed25519";
    };

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
  };

}
