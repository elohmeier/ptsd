{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.ptsd.offlineimap;
  dag = import <home-manager/modules/lib/dag.nix> { inherit lib; };
in
{
  options.ptsd.offlineimap = {
    enable = mkEnableOption "offlineimap: userspace pass-enabled offlineimap setup";
    # TODO: generate offlineimaprc in module
    offlineimaprc = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {

    systemd.user.services.offlineimap = {
      Unit = {
        Description = "Offlineimap";
        Wants = [ "network-online.target" ];
        Requires = [ "gpg-agent.service" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.offlineimap}/bin/offlineimap";
        TimeoutStartSec = "5min"; # kill if still alive after 5 minutes
      };
    };

    systemd.user.timers.offlineimap = {
      Unit = {
        Description = "Offlineimap Timer";
        PartOf = [ "graphical-session.target" ];
        WantedBy = [ "graphical-session.target" ];
      };

      Timer = {
        OnBootSec = "2min";
        OnUnitInactiveSec = "2min";
      };
    };

    xdg.configFile."offlineimap/get_settings.py".text = ''
      from subprocess import check_output

      def get_pass(account):
          return check_output("${pkgs.pass}/bin/pass mail/" + account, shell=True).splitlines()[0]
    '';
    xdg.configFile."offlineimap/config".text = cfg.offlineimaprc;

    # offlineimap will load the pyc file instead of the propably newer .py-File, which can
    # lead to weird errors. Thus we always delete the .pyc when activating
    home.activation.deleteOfflineImapPyc = dag.dagEntryAfter [ "writeBoundary" ] ''
      rm -f "${config.xdg.configHome}/offlineimap/get_settings.pyc";
    '';
  };
}
