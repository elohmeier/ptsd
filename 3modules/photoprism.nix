{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.photoprism;
  configOptions = {
    debug = true;

    originals-path = "/var/lib/photoprism/originals";
    import-path = "/var/lib/photoprism/import";

    darktable-bin = "${pkgs.darktable}/bin/darktable";
    rawtherapee-bin = "${pkgs.rawtherapee}/bin/rawtherapee";
    heifconvert-bin = "${pkgs.libheif}/bin/heif-convert";
    ffmpeg-bin = "${pkgs.ffmpeg}/bin/ffmpeg";
    exiftool-bin = "${pkgs.exiftool}/bin/exiftool";
  };
  configFile = pkgs.runCommand "config.toml" { buildInputs = [ pkgs.remarshal ]; preferLocalBuild = true; }
    ''
      remarshal -if json -of toml \
        < ${pkgs.writeText "config.json"
        (builtins.toJSON configOptions)} \
        > $out
    '';
in
{
  options.ptsd.photoprism = {
    enable = mkEnableOption "photoprism";
    domain = mkOption { type = types.str; };
    package = mkOption {
      type = types.package;
      default = pkgs.photoprism;
      defaultText = "pkgs.photoprism";
    };
  };

  config = mkIf cfg.enable {

    environment.variables = {
      PHOTOPRISM_CONFIG_FILE = toString configFile;
    };
    environment.systemPackages = [ cfg.package ];

    systemd.services.photoprism = {
      description = "PhotoPrism Photo Management";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];

      preStart = ''

        mkdir -p /var/lib/photoprism/originals
        mkdir -p /var/lib/photoprism/import
        '';

      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/photoprism -c ${configFile} --assets-path "${cfg.package}/assets" start'';
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        CapabilityBoundingSet = "cap_net_bind_service";
        AmbientCapabilities = "cap_net_bind_service";
        NoNewPrivileges = true;
        DynamicUser = true;
        StateDirectory = "photoprism";
        Restart = "on-failure";
      };
    };

  };

}
