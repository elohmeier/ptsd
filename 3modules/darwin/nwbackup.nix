{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.nwbackup;

  mkExcludeFile = cfg:
    # Write each exclude pattern to a new line
    pkgs.writeText "excludefile" (concatStringsSep "\n" cfg.exclude);

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
      --exclude-from ${mkExcludeFile cfg} \
      \
      ::$archiveName \
      ${escapeShellArgs cfg.paths}
  '';
  script-init = pkgs.writers.writeDashBin "nwbackup-nas1-init" ''
    ${pkgs.borgbackup}/bin/borg init -e repokey-blake2
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
      paths = mkOption {
        type = with types; coercedTo str lib.singleton (listOf str);
        description = "Path(s) to back up.";
        example = "/home/user";
      };
      exclude = mkOption {
        type = with types; listOf str;
        description = ''
          Exclude paths matching any of the given patterns. See
          <command>borg help patterns</command> for pattern syntax.
        '';
        default = [
          "/Users/*/.cache/*"
          "/Users/*/Applications/*"
          "/Users/*/Library/Caches/*"
          "/Users/*/.Trash/*"
          "/*/.Trashes"
          "/*/.DS_Store"
          "/*/.Spotlight-V100"
          "/*/.fseventsd"
        ];
        example = [
          "/home/*/.cache"
          "/nix"
        ];
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      script
      script-init
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
        StartCalendarInterval = [{ Hour = 11; Minute = 0; }];
      };
    };
  };
}
