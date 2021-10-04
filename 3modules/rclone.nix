{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.ptsd.rclone;

  configFile = pkgs.writeTextFile {
    name = "rclone.conf";
    text = lib.generators.toINI { } cfg.config;
  };

  mkJobService = name: jobCfg:
    nameValuePair "rclone-${name}" {
      description = "rclone job ${name}";
      path = with pkgs; [ rclone ];
      script = jobCfg.script;
      serviceConfig = {
        # execution
        Type = "oneshot";
        LoadCredential = mapAttrsToList (id: path: "${id}:${path}") cfg.credentials;
        SupplementaryGroups = mkIf (jobCfg.groups != [ ]) jobCfg.groups;
        ReadWritePaths = mkIf (jobCfg.rwpaths != [ ]) jobCfg.rwpaths;

        # hardening
        DynamicUser = jobCfg.user == null;
        User = mkIf (jobCfg.user != null) jobCfg.user;
        Group = mkIf (jobCfg.group != null) jobCfg.group;
        StartLimitBurst = 5;
        NoNewPrivileges = true;
        LimitNPROC = 64;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "noaccess";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
        RestrictNamespaces = true;
        DevicePolicy = "closed";
        RestrictRealtime = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        SystemCallArchitectures = "native";
        UMask = "0066";
      };
      environment = {
        RCLONE_CONFIG = toString configFile;
      };
      wants = [ "network.target" "network-online.target" ];
      startAt = mkIf (jobCfg.startAt != null) jobCfg.startAt;
    };
in
{
  options = {
    ptsd.rclone = {
      config = mkOption {
        type = types.attrs;
        default = { };
      };

      credentials = mkOption {
        type = with types; attrsOf str;
        default = { };
      };

      jobs = mkOption {
        description = "rclone jobs to configure";
        type = types.attrsOf (
          types.submodule (
            { config, ... }: {
              options = {
                name = mkOption {
                  type = types.str;
                  default = config._module.args.name;
                };
                script = mkOption {
                  type = types.str;
                };
                user = mkOption {
                  type = types.str;
                  default = null;
                };
                group = mkOption {
                  type = types.str;
                  default = null;
                };
                groups = mkOption {
                  type = with types; listOf str;
                  default = [ ];
                };
                rwpaths = mkOption {
                  type = with types; listOf str;
                  default = [ ];
                };
                startAt = mkOption {
                  type = types.str;
                  default = null;
                };
              };
            }
          )
        );
        default = { };
      };
    };
  };

  config = mkIf (cfg.jobs != [ ]) {
    systemd.services = mapAttrs' mkJobService cfg.jobs;
  };
}
