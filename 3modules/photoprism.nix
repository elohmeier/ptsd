{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.photoprism;

  cmd = ''
    ${cfg.package}/bin/photoprism \
      --sponsor \
      --http-host "${cfg.httpHost}" \
      --http-port "${toString cfg.httpPort}" \
      --site-title "PhotoPrism" \
      --site-caption "Browse Your Life" \
      --site-url "${cfg.siteUrl}" \
      --import-path "${cfg.photosDirectory}/import" \
      --originals-path "${cfg.photosDirectory}/originals" \
      --assets-path "${cfg.package}/assets" \
      --darktable-bin "${pkgs.darktable}/bin/darktable-cli" \
      --rawtherapee-bin "${pkgs.rawtherapee}/bin/rawtherapee-cli" \
      --heifconvert-bin "${pkgs.libheif}/bin/heif-convert" \
      --ffmpeg-bin "${pkgs.ffmpeg}/bin/ffmpeg" \
      --exiftool-bin "${pkgs.exiftool}/bin/exiftool" \
      --cache-path "${cfg.cacheDirectory}" \
      --storage-path "${cfg.dataDirectory}" ${concatStringsSep " " cfg.extraArgs}'';
in
{
  options.ptsd.photoprism = {
    enable = mkEnableOption "photoprism";
    httpHost = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
    httpPort = mkOption {
      type = types.int;
      default = config.ptsd.nwtraefik.ports.photoprism;
    };
    siteUrl = mkOption {
      type = types.str;
      default = "http://localhost:${toString config.ptsd.nwtraefik.ports.photoprism}/";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.photoprism;
      defaultText = "pkgs.photoprism";
    };
    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
    dataDirectory = mkOption {
      type = types.str;
      default = "/var/lib/photoprism";
    };
    cacheDirectory = mkOption {
      type = types.str;
      default = "/var/cache/photoprism";
    };
    photosDirectory = mkOption {
      type = types.str;
      default = "/var/lib/photoprism";
      description = "folder containing `originals` & `import` folders";
    };
    user = mkOption {
      type = types.str;
      default = "photoprism";
    };
    group = mkOption {
      type = types.str;
      default = "photoprism";
    };
    autostart = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package pkgs.exiftool ];

    users.groups.rawphotos = { };

    ptsd.secrets.files."photoprism.env" = {
      dependants = [ "photoprism.service" ];
    };

    systemd.services.photoprism = {
      description = "PhotoPrism Photo Management";
      wantedBy = mkIf cfg.autostart [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      preStart = ''
        mkdir -p "${cfg.photosDirectory}/originals"
        mkdir -p "${cfg.photosDirectory}/import"
      '';

      script = ''
        ${cmd} config
        ${cmd} start
      '';

      environment = {
        HOME = cfg.dataDirectory; # fix glib warning
      };

      serviceConfig = {
        # execution
        Restart = "on-failure";

        # folders
        StateDirectory = "photoprism";
        CacheDirectory = "photoprism";
        EnvironmentFile = config.ptsd.secrets.files."photoprism.env".path;

        # hardening
        #DynamicUser = true;
        User = cfg.user; # needs to be set for shared uid
        Group = cfg.group;
        #  SupplementaryGroups = "rawphotos";
        #  StartLimitBurst = 5;
        #  AmbientCapabilities = "cap_net_bind_service";
        #  CapabilityBoundingSet = "cap_net_bind_service";
        #  NoNewPrivileges = true;
        #  LimitNPROC = 64;
        #  LimitNOFILE = 1048576;
        #  PrivateTmp = true;
        #  PrivateDevices = true;
        #  PrivateUsers = true;
        #  ProtectHome = true;
        #  ProtectSystem = "strict";
        #  ProtectControlGroups = true;
        #  ProtectClock = true;
        #  ProtectHostname = true;
        #  ProtectKernelLogs = true;
        #  ProtectKernelModules = true;
        #  ProtectKernelTunables = true;
        #  ProtectProc = "noaccess";
        #  LockPersonality = true;
        #  MemoryDenyWriteExecute = true;
        #  RestrictAddressFamilies = "AF_INET AF_INET6";
        #  RestrictNamespaces = true;
        #  DevicePolicy = "closed";
        #  RestrictRealtime = true;
        #  SystemCallFilter = "@system-service";
        #  SystemCallErrorNumber = "EPERM";
        #  SystemCallArchitectures = "native";
        #  UMask = "0066";
        #  IPAddressAllow = cfg.httpHost;
      };
    };

    systemd.services.photoprism-index = {
      description = "PhotoPrism: index media files in originals folder";
      environment = {
        HOME = cfg.dataDirectory; # fix glib warning
      };

      script = ''
        ${cmd} index
      '';

      serviceConfig = {
        # execution
        Type = "oneshot";

        # folders
        StateDirectory = "photoprism";
        CacheDirectory = "photoprism";
        EnvironmentFile = config.ptsd.secrets.files."photoprism.env".path;

        # hardening
        #DynamicUser = true;
        User = cfg.user; # needs to be set for shared uid
        Group = cfg.group;
        #  SupplementaryGroups = "rawphotos";
        #  NoNewPrivileges = true;
        #  LimitNPROC = 64;
        #  LimitNOFILE = 1048576;
        #  PrivateTmp = true;
        #  PrivateDevices = true;
        #  PrivateUsers = true;
        #  ProtectHome = true;
        #  ProtectSystem = "strict";
        #  ProtectControlGroups = true;
        #  ProtectClock = true;
        #  ProtectHostname = true;
        #  ProtectKernelLogs = true;
        #  ProtectKernelModules = true;
        #  ProtectKernelTunables = true;
        #  ProtectProc = "noaccess";
        #  LockPersonality = true;
        #  MemoryDenyWriteExecute = true;
        #  RestrictAddressFamilies = "";
        #  RestrictNamespaces = true;
        #  DevicePolicy = "closed";
        #  RestrictRealtime = true;
        #  SystemCallFilter = "@system-service";
        #  SystemCallErrorNumber = "EPERM";
        #  SystemCallArchitectures = "native";
        #  UMask = "0066";
      };
    };

  };

}
