{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwbackup;
  script = pkgs.writers.writeDashBin "nwbackup-nas1" ''
    set -e

    archiveName="$(hostname -s)-$(date +%Y-%m-%dT%H:%M:%S)"

    ${pkgs.borgbackup}/bin/borg create \
      --verbose \
      --filter AME \
      --list \
      --stats \
      --show-rc \
      --compression auto,lzma,6 \
      --exclude-caches \
      --exclude '/Users/*/.cache/*' \
      --exclude '/Users/*/Applications/*' \
      --exclude '/Users/*/Library/Caches/*' \
      --exclude '/Users/*/.Trash/* ' \
      --exclude '/Users/*/.DS_Store' \
      \
      ::$archiveName \
      $HOME
  '';
in
{
  options = {
    ptsd.nwbackup = {
      enable = mkEnableOption "nwbackup";
      passCommand = mkOption {
        default = "${pkgs.python3Packages.keyring}/bin/keyring get borg nwbackup";
        type = types.str;
      };
      repo = mkOption {
        default = "borg-${config.networking.hostName}@192.168.178.12:.";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      script
      pkgs.python3Packages.keyring
    ];

    environment.variables = {
      BORG_PASSCOMMAND = cfg.passCommand;
      BORG_REPO = cfg.repo;
    };

    launchd.user.agents."nwbackup-nas1" = {
      script = "${script}/bin/nwbackup-nas1";
      serviceConfig = {
        ProcessType = "Interactive";
        StartCalendarInterval = [ { Hour = 11; Minute = 0; } ];
      };
    };
  };
}
