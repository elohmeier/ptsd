{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.photoprism;

  cmd = ''
    ${cfg.package}/bin/photoprism \
      --read-only \
      --http-host "${cfg.httpHost}" \
      --http-port "${toString cfg.httpPort}" \
      --site-title "PhotoPrism" \
      --site-caption "Browse Your Life" \
      --site-url "${cfg.siteUrl}" \
      --import-path "/var/lib/photoprism/import" \
      --originals-path "/var/lib/photoprism/originals" \
      --assets-path "${cfg.package}/assets" \
      --darktable-bin "${pkgs.darktable}/bin/darktable" \
      --rawtherapee-bin "${pkgs.rawtherapee}/bin/rawtherapee" \
      --heifconvert-bin "${pkgs.libheif}/bin/heif-convert" \
      --ffmpeg-bin "${pkgs.ffmpeg}/bin/ffmpeg" \
      --exiftool-bin "${pkgs.exiftool}/bin/exiftool" \
      --log-filename "$LOGS_DIRECTORY/photoprism.log" \
      --pid-filename "$RUNTIME_DIRECTORY/photoprism.pid" \
      --cache-path "$CACHE_DIRECTORY" \
      --storage-path "$STATE_DIRECTORY" ${concatStringsSep " " cfg.extraArgs}'';
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
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    ptsd.secrets.files."photoprism.env" = {
      dependants = [ "photoprism.service" ];
    };

    systemd.services.photoprism = {
      description = "PhotoPrism Photo Management";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      preStart = ''
        mkdir -p /var/lib/photoprism/originals
        mkdir -p /var/lib/photoprism/import
      '';

      script = ''
        ${cmd} config
        ${cmd} start
      '';

      serviceConfig = {
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        AmbientCapabilities = "cap_net_bind_service";
        NoNewPrivileges = true;
        DynamicUser = true;
        RuntimeDirectory = "photoprism";
        StateDirectory = "photoprism";
        CacheDirectory = "photoprism";
        LogsDirectory = "photoprism";
        Restart = "on-failure";
        EnvironmentFile = config.ptsd.secrets.files."photoprism.env".path;
      };
    };

  };

}
