{ config, pkgs, lib, ... }:

with lib;
let
  fraamCfg = import ./fraam-gdrives.nix;

  genCfg = drive_name: drive_id: nameValuePair
    drive_name
    {
      type = "drive";
      client_id = "100812309064118189865";
      scope = "drive.readonly";
      service_account_file = "$CREDENTIALS_DIRECTORY/gdrive-key";
      impersonate = "klaus.stammerjohann@fraam.de";
      team_drive = drive_id;
    };

  genJob = drive_name: drive_id: nameValuePair
    drive_name
    {
      # add `--dry-run` to test the command
      cmd = "sync --drive-skip-shortcuts ${drive_name}: /tank/enc/fraam-gdrive-backup/${drive_id}";
      user = "fraam-gdrive-backup";
      group = "fraam-gdrive-backup";
      rwpaths = [ "/tank/enc/fraam-gdrive-backup" ];
      startAt = "*-*-* 05:00:00";
    };
in
{
  users.groups.fraam-gdrive-backup = { };
  users.users.fraam-gdrive-backup = {
    description = "fraam-gdrive-backup user";
    isSystemUser = true;
    group = "fraam-gdrive-backup";
  };

  ptsd.rclone = {
    config = mapAttrs' genCfg fraamCfg.drives;
    jobs = mapAttrs' genJob fraamCfg.drives;

    credentials =
      {
        "gdrive-key" = "/var/src/secrets/fraam-gdrive-backup-3b42c04ff1ec.json";
      };
  };
}
