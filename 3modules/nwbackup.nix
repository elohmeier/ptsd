{ config, lib, pkgs, ... }:

with lib;

let
  postCreatePrometheus = name: ''
    TMP_FILE=`mktemp`
    PROM_TAG="{target=\"${name}\", host=\"${config.networking.hostName}\"}"
    echo backup_completion_time$PROM_TAG $(date +%s) > $TMP_FILE

    LIST=$(${pkgs.borgbackup}/bin/borg list |${pkgs.gawk}/bin/awk '{print $1}')
    COUNTER=0
    for i in $LIST; do
      COUNTER=$((COUNTER+1))
    done

    BORG_INFO=$(${pkgs.borgbackup}/bin/borg info "::$archiveName")

    echo "backup_count$PROM_TAG $COUNTER" >> $TMP_FILE
    echo "backup_files$PROM_TAG $(echo "$BORG_INFO" | grep "Number of files" | ${pkgs.gawk}/bin/awk '{print $4}')" >> $TMP_FILE
    echo "backup_chunks_unique$PROM_TAG $(echo "$BORG_INFO" | grep "Chunk index" | ${pkgs.gawk}/bin/awk '{print $3}')" >> $TMP_FILE
    echo "backup_chunks_total$PROM_TAG $(echo "$BORG_INFO" | grep "Chunk index" | ${pkgs.gawk}/bin/awk '{print $4}')" >> $TMP_FILE

    function calc_bytes {
      NUM=$1
      UNIT=$2

      case "$UNIT" in
        kB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 }'
          ;;
        MB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 * 1024 }'
          ;;
        GB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 * 1024 * 1024 }'
          ;;
        TB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 * 1024 * 1024 * 1024 }'
          ;;
      esac
    }

    # byte size
    LAST_SIZE=$(calc_bytes $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $3}') $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $4}'))
    LAST_SIZE_COMPRESSED=$(calc_bytes $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $5}') $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $6}'))
    LAST_SIZE_DEDUP=$(calc_bytes $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $7}') $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $8}'))
    TOTAL_SIZE=$(calc_bytes $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $3}') $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $4}'))
    TOTAL_SIZE_COMPRESSED=$(calc_bytes $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $5}') $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $6}'))
    TOTAL_SIZE_DEDUP=$(calc_bytes $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $7}') $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $8}'))

    echo "backup_last_size$PROM_TAG $LAST_SIZE" >> $TMP_FILE
    echo "backup_last_size_compressed$PROM_TAG $LAST_SIZE_COMPRESSED" >> $TMP_FILE
    echo "backup_last_size_dedup$PROM_TAG $LAST_SIZE_DEDUP" >> $TMP_FILE
    echo "backup_total_size$PROM_TAG $TOTAL_SIZE" >> $TMP_FILE
    echo "backup_total_size_compressed$PROM_TAG $TOTAL_SIZE_COMPRESSED" >> $TMP_FILE
    echo "backup_total_size_dedup$PROM_TAG $TOTAL_SIZE_DEDUP" >> $TMP_FILE

    mv $TMP_FILE /var/log/borg_backup_${name}.prom
    chmod o+r /var/log/borg_backup_${name}.prom
  '';

  postCreateTelegraf = name: ''
    TMP_FILE=`mktemp`
    IQL_PREFIX="borgbackup,target=\"${name}\",host=\"${config.networking.hostName}\""
    echo $IQL_PREFIX backup_completion_time=$(date +%s) > $TMP_FILE

    LIST=$(${pkgs.borgbackup}/bin/borg list |${pkgs.gawk}/bin/awk '{print $1}')
    COUNTER=0
    for i in $LIST; do
      COUNTER=$((COUNTER+1))
    done

    BORG_INFO=$(${pkgs.borgbackup}/bin/borg info "::$archiveName")

    echo "$IQL_PREFIX backup_count=$COUNTER" >> $TMP_FILE
    echo "$IQL_PREFIX backup_files=$(echo "$BORG_INFO" | grep "Number of files" | ${pkgs.gawk}/bin/awk '{print $4}')" >> $TMP_FILE
    echo "$IQL_PREFIX backup_chunks_unique=$(echo "$BORG_INFO" | grep "Chunk index" | ${pkgs.gawk}/bin/awk '{print $3}')" >> $TMP_FILE
    echo "$IQL_PREFIX backup_chunks_total=$(echo "$BORG_INFO" | grep "Chunk index" | ${pkgs.gawk}/bin/awk '{print $4}')" >> $TMP_FILE

    function calc_bytes {
      NUM=$1
      UNIT=$2

      case "$UNIT" in
        kB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 }'
          ;;
        MB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 * 1024 }'
          ;;
        GB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 * 1024 * 1024 }'
          ;;
        TB)
          echo $NUM | ${pkgs.gawk}/bin/awk '{ print $1 * 1024 * 1024 * 1024 * 1024 }'
          ;;
      esac
    }

    # byte size
    LAST_SIZE=$(calc_bytes $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $3}') $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $4}'))
    LAST_SIZE_COMPRESSED=$(calc_bytes $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $5}') $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $6}'))
    LAST_SIZE_DEDUP=$(calc_bytes $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $7}') $(echo "$BORG_INFO" |grep "This archive" |${pkgs.gawk}/bin/awk '{print $8}'))
    TOTAL_SIZE=$(calc_bytes $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $3}') $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $4}'))
    TOTAL_SIZE_COMPRESSED=$(calc_bytes $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $5}') $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $6}'))
    TOTAL_SIZE_DEDUP=$(calc_bytes $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $7}') $(echo "$BORG_INFO" |grep "All archives" |${pkgs.gawk}/bin/awk '{print $8}'))

    echo "$IQL_PREFIX backup_last_size=$LAST_SIZE" >> $TMP_FILE
    echo "$IQL_PREFIX backup_last_size_compressed=$LAST_SIZE_COMPRESSED" >> $TMP_FILE
    echo "$IQL_PREFIX backup_last_size_dedup=$LAST_SIZE_DEDUP" >> $TMP_FILE
    echo "$IQL_PREFIX backup_total_size=$TOTAL_SIZE" >> $TMP_FILE
    echo "$IQL_PREFIX backup_total_size_compressed=$TOTAL_SIZE_COMPRESSED" >> $TMP_FILE
    echo "$IQL_PREFIX backup_total_size_dedup=$TOTAL_SIZE_DEDUP" >> $TMP_FILE

    mv $TMP_FILE /var/log/borg_backup_${name}.iql
    chmod o+r /var/log/borg_backup_${name}.iql
  '';

  generateJob = name: values:
    nameValuePair "nwbackup-${name}" {
      paths = cfg.paths;
      repo = values;
      encryption = {
        mode = "repokey";
        passCommand = cfg.passCommand;
      };
      compression = "auto,lzma,6";
      doInit = false;
      exclude = cfg.exclude;
      extraCreateArgs = "--stats --exclude-caches";
      environment = { BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes"; };
      postCreate = postCreateTelegraf name;
      readWritePaths = [ "/var/log" ];
      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
    };

  mkInitRepoService = name: repoAddress:
    nameValuePair "nwbackup-init-repo-${name}" {
      description = "Initialize BorgBackup repository ${name}";
      script = ''
        if ${pkgs.borgbackup}/bin/borg info; then
          echo "borg repo exists, skipping initialization"
        else
          echo "initializing borg repo ${repoAddress}"
          ${pkgs.borgbackup}/bin/borg init -e repokey-blake2
        fi
      '';
      serviceConfig = {
        Type = "oneshot";

      };
      environment = {
        BORG_REPO = repoAddress;
        BORG_PASSCOMMAND = cfg.passCommand;
        BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
      };
      wantedBy = [ "multi-user.target" ];
    };

  cfg = config.ptsd.nwbackup;
in
{

  options = {
    ptsd.nwbackup = {
      enable = mkEnableOption "nwbackup";
      passCommand = mkOption {
        default = "cat ${toString <secrets>}/nwbackup.borgkey";
        type = types.str;
      };
      paths = mkOption {
        default = [ "/etc" "/home" "/root" "/var/db" "/var/lib" "/var/spool" ];
        type = with types; coercedTo str lib.singleton (listOf str);
      };
      exclude = mkOption {
        default = [
          "/home/*/.android"
          "/home/*/.cache"
          "/home/*/.local"
          "/home/*/.minishift"
          "/home/*/.wine/drive_c/Program Files/Steam"
          "/home/*/.PyCharm*"
          "/home/*/nixpkgs"
          "/home/*/.meteor"
          "/home/*/.npm"
          "/home/*/Downloads"
          "*.pyc"
          "/var/lib/libvirt"
          "/var/lib/docker"
        ];
        type = with types; listOf str;
      };
      repos = mkOption {
        default = {
          nuc1 = "borg-${config.networking.hostName}@nuc1.host.nerdworks.de:.";
          #eee1 = "borg-${config.networking.hostName}@eee1.host.nerdworks.de:."; # temporarily unavailable
        };
        type = with types; attrsOf str;
      };
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs = mapAttrs' generateJob cfg.repos;

    systemd.services = mapAttrs' mkInitRepoService cfg.repos;

    environment.variables = {
      BORG_REPO = "borg-${config.networking.hostName}@nuc1.host.nerdworks.de:.";
      BORG_PASSCOMMAND = cfg.passCommand;
      BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
    };

    ptsd.nwtelegraf.extraConfig.inputs.file = [
      {
        files = [ "/var/log/borg_backup_*.iql" ];
        data_format = "influx";
      }
    ];
  };
}
