{ config, lib, pkgs, ... }:

with lib;
let
  mkExcludeFile = cfg:
    # Write each exclude pattern to a new line
    pkgs.writeText "excludefile" (concatStringsSep "\n" cfg.exclude);

  mkBackupScript = cfg: ''
    on_exit()
    {
      exitStatus=$?
      # Reset the EXIT handler, or else we're called again on 'exit' below
      trap - EXIT
      ${cfg.postHook}
      exit $exitStatus
    }
    trap 'on_exit' INT TERM QUIT EXIT

    archiveName="${if cfg.archiveBaseName == null then "" else cfg.archiveBaseName + "-"}$(date ${cfg.dateFormat})"
    archiveSuffix="${optionalString cfg.appendFailedSuffix ".failed"}"
    ${cfg.preHook}
  '' + optionalString cfg.doInit ''
    # Run borg init if the repo doesn't exist yet
    if ! borg list $extraArgs > /dev/null; then
      borg init $extraArgs \
        --encryption ${cfg.encryption.mode} \
        $extraInitArgs
      ${cfg.postInit}
    fi
  '' + ''
    (
      set -o pipefail
      ${optionalString (cfg.dumpCommand != null) ''${escapeShellArg cfg.dumpCommand} | \''}
      borg create $extraArgs \
        --compression ${cfg.compression} \
        --exclude-from ${mkExcludeFile cfg} \
        $extraCreateArgs \
        "::$archiveName$archiveSuffix" \
        ${if cfg.paths == null then "-" else escapeShellArgs cfg.paths}
    )
  '' + optionalString cfg.appendFailedSuffix ''
    borg rename $extraArgs \
      "::$archiveName$archiveSuffix" "$archiveName"
  '' + ''
    ${cfg.postCreate}
  '' + optionalString (cfg.prune.keep != { }) ''
    borg prune $extraArgs \
      ${mkKeepArgs cfg} \
      ${optionalString (cfg.prune.prefix != null) "--prefix ${escapeShellArg cfg.prune.prefix} \\"}
      $extraPruneArgs
    ${cfg.postPrune}
  '';

  # utility function around makeWrapper
  mkWrapperDrv =
    { original
    , name
    , set ? { }
    }:
    pkgs.runCommand "${name}-wrapper"
      {
        buildInputs = [ pkgs.makeWrapper ];
      }
      (with lib; ''
        makeWrapper "${original}" "$out/bin/${name}" \
          ${concatStringsSep " \\\n " (mapAttrsToList (name: value: ''--set ${name} "${value}"'') set)}
      '');

  mkPassEnv = cfg: with cfg.encryption;
    if passCommand != null then
      { BORG_PASSCOMMAND = passCommand; }
    else if passphrase != null then
      { BORG_PASSPHRASE = passphrase; }
    else { };

  mkBorgWrapper = name: cfg: mkWrapperDrv {
    original = "${pkgs.borgbackup}/bin/borg";
    name = "borg-job-${name}";
    set = { BORG_REPO = cfg.repo; } // (mkPassEnv cfg) // cfg.environment;
  };

  mkBackupLaunchdAgent = name: cfg: nameValuePair "borgbackup-job-${name}" {
    enable = true;
    config = {
      EnvironmentVariables = {
        BORG_REPO = cfg.repo;
        PATH = lib.makeBinPath (with pkgs;[ coreutils borgbackup openssh ]);
        inherit (cfg) extraArgs extraInitArgs extraCreateArgs extraPruneArgs;
      } // (mkPassEnv cfg) // cfg.environment;
      LowPriorityBackgroundIO = true;
      ProcessType = "Background";
      Program = toString (pkgs.writeShellScript "borgbackup-script-${name}" (mkBackupScript cfg));
      StartCalendarInterval = [{ Hour = 10; Minute = 0; }];
    };
  };
in
{
  options = {
    ptsd.borgbackup.jobs = mkOption {
      default = { };
      type = types.attrsOf (types.submodule ({ name, config, ... }: {
        options = {
          paths = mkOption {
            type = with types; nullOr (coercedTo str lib.singleton (listOf str));
            default = null;
            description = lib.mdDoc ''
              Path(s) to back up.
              Mutually exclusive with {option}`dumpCommand`.
            '';
            example = "/home/user";
          };

          dumpCommand = mkOption {
            type = with types; nullOr path;
            default = null;
            description = lib.mdDoc ''
              Backup the stdout of this program instead of filesystem paths.
              Mutually exclusive with {option}`paths`.
            '';
            example = "/path/to/createZFSsend.sh";
          };

          repo = mkOption {
            type = types.str;
            description = lib.mdDoc "Remote or local repository to back up to.";
            example = "user@machine:/path/to/repo";
          };

          archiveBaseName = mkOption {
            type = types.nullOr (types.strMatching "[^/{}]+");
            default = "${name}";
            defaultText = literalExpression ''"<name>"'';
            description = lib.mdDoc ''
              How to name the created archives. A timestamp, whose format is
              determined by {option}`dateFormat`, will be appended. The full
              name can be modified at runtime (`$archiveName`).
              Placeholders like `{hostname}` must not be used.
              Use `null` for no base name.
            '';
          };

          dateFormat = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              Arguments passed to {command}`date`
              to create a timestamp suffix for the archive name.
            '';
            default = "+%Y-%m-%dT%H:%M:%S";
            example = "-u +%s";
          };

          encryption.mode = mkOption {
            type = types.enum [
              "repokey"
              "keyfile"
              "repokey-blake2"
              "keyfile-blake2"
              "authenticated"
              "authenticated-blake2"
              "none"
            ];
            description = lib.mdDoc ''
              Encryption mode to use. Setting a mode
              other than `"none"` requires
              you to specify a {option}`passCommand`
              or a {option}`passphrase`.
            '';
            example = "repokey-blake2";
          };

          encryption.passCommand = mkOption {
            type = with types; nullOr str;
            description = lib.mdDoc ''
              A command which prints the passphrase to stdout.
              Mutually exclusive with {option}`passphrase`.
            '';
            default = null;
            example = "cat /path/to/passphrase_file";
          };

          encryption.passphrase = mkOption {
            type = with types; nullOr str;
            description = lib.mdDoc ''
              The passphrase the backups are encrypted with.
              Mutually exclusive with {option}`passCommand`.
              If you do not want the passphrase to be stored in the
              world-readable Nix store, use {option}`passCommand`.
            '';
            default = null;
          };

          compression = mkOption {
            # "auto" is optional,
            # compression mode must be given,
            # compression level is optional
            type = types.strMatching "none|(auto,)?(lz4|zstd|zlib|lzma)(,[[:digit:]]{1,2})?";
            description = lib.mdDoc ''
              Compression method to use. Refer to
              {command}`borg help compression`
              for all available options.
            '';
            default = "lz4";
            example = "auto,lzma";
          };

          exclude = mkOption {
            type = with types; listOf str;
            description = lib.mdDoc ''
              Exclude paths matching any of the given patterns. See
              {command}`borg help patterns` for pattern syntax.
            '';
            default = [ ];
            example = [
              "/home/*/.cache"
              "/nix"
            ];
          };

          doInit = mkOption {
            type = types.bool;
            description = lib.mdDoc ''
              Run {command}`borg init` if the
              specified {option}`repo` does not exist.
              You should set this to `false`
              if the repository is located on an external drive
              that might not always be mounted.
            '';
            default = true;
          };

          appendFailedSuffix = mkOption {
            type = types.bool;
            description = lib.mdDoc ''
              Append a `.failed` suffix
              to the archive name, which is only removed if
              {command}`borg create` has a zero exit status.
            '';
            default = true;
          };

          prune.keep = mkOption {
            # Specifying e.g. `prune.keep.yearly = -1`
            # means there is no limit of yearly archives to keep
            # The regex is for use with e.g. --keep-within 1y
            type = with types; attrsOf (either int (strMatching "[[:digit:]]+[Hdwmy]"));
            description = lib.mdDoc ''
              Prune a repository by deleting all archives not matching any of the
              specified retention options. See {command}`borg help prune`
              for the available options.
            '';
            default = { };
            example = literalExpression ''
              {
                within = "1d"; # Keep all archives from the last day
                daily = 7;
                weekly = 4;
                monthly = -1;  # Keep at least one archive for each month
              }
            '';
          };

          prune.prefix = mkOption {
            type = types.nullOr (types.str);
            description = lib.mdDoc ''
              Only consider archive names starting with this prefix for pruning.
              By default, only archives created by this job are considered.
              Use `""` or `null` to consider all archives.
            '';
            default = config.archiveBaseName;
            defaultText = literalExpression "archiveBaseName";
          };

          environment = mkOption {
            type = with types; attrsOf str;
            description = lib.mdDoc ''
              Environment variables passed to the backup script.
              You can for example specify which SSH key to use.
            '';
            default = { };
            example = { BORG_RSH = "ssh -i /path/to/key"; };
          };

          preHook = mkOption {
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands to run before the backup.
              This can for example be used to mount file systems.
            '';
            default = "";
            example = ''
              # To add excluded paths at runtime
              extraCreateArgs="$extraCreateArgs --exclude /some/path"
            '';
          };

          postInit = mkOption {
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands to run after {command}`borg init`.
            '';
            default = "";
          };

          postCreate = mkOption {
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands to run after {command}`borg create`. The name
              of the created archive is stored in `$archiveName`.
            '';
            default = "";
          };

          postPrune = mkOption {
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands to run after {command}`borg prune`.
            '';
            default = "";
          };

          postHook = mkOption {
            type = types.lines;
            description = lib.mdDoc ''
              Shell commands to run just before exit. They are executed
              even if a previous command exits with a non-zero exit code.
              The latter is available as `$exitStatus`.
            '';
            default = "";
          };

          extraArgs = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              Additional arguments for all {command}`borg` calls the
              service has. Handle with care.
            '';
            default = "";
            example = "--remote-path=/path/to/borg";
          };

          extraInitArgs = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              Additional arguments for {command}`borg init`.
              Can also be set at runtime using `$extraInitArgs`.
            '';
            default = "";
            example = "--append-only";
          };

          extraCreateArgs = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              Additional arguments for {command}`borg create`.
              Can also be set at runtime using `$extraCreateArgs`.
            '';
            default = "";
            example = "--stats --checkpoint-interval 600";
          };

          extraPruneArgs = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              Additional arguments for {command}`borg prune`.
              Can also be set at runtime using `$extraPruneArgs`.
            '';
            default = "";
            example = "--save-space";
          };

        };
      }));
    };
  };

  config = mkIf (config.ptsd.borgbackup.jobs != { }) (with config.ptsd.borgbackup; {

    home.packages = [ pkgs.borgbackup ] ++ (mapAttrsToList mkBorgWrapper jobs);

    launchd.agents = mapAttrs' mkBackupLaunchdAgent jobs;

    # TODO
    # launchd.user.agents."nwbackup-nas1" = {
    #   script = "${script}/bin/nwbackup-nas1";
    #   serviceConfig = {
    #     ProcessType = "Interactive";
    #     StartCalendarInterval = [{ Hour = 11; Minute = 0; }];
    #   };
    # };
  });
}
