{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ptsd.desktop;
in
{
  environment.variables = optionalAttrs cfg.rclone.enable {
    RCLONE_CONFIG =
      let
        fraamCfg = import ../../2configs/fraam-gdrives.nix;
        genCfg = drive_name: drive_id: nameValuePair drive_name {
          type = "drive";
          client_id = "100812309064118189865";
          scope = "drive";
          service_account_file = config.ptsd.secrets.files."fraam-gdrive-backup-3b42c04ff1ec.json".path;
          impersonate = "enno.richter@fraam.de";
          team_drive = drive_id;
        };
      in
      toString (pkgs.writeText "rclone.conf" (generators.toINI { } (mapAttrs' genCfg fraamCfg.drives)));
  };
}
