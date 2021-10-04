{ config, pkgs, lib, ... }:

with lib;
let
  fraamCfg = import ../../../2configs/fraam-gdrives.nix;

  genCfg = drive_name: drive_id: nameValuePair
    drive_name
    {
      type = "drive";
      client_id = "110476733789902981992";
      # scope = "drive.readonly";
      scope = "drive"; # write-access required for dedupe operation
      service_account_file = "$CREDENTIALS_DIRECTORY/gdrive-key";
      impersonate = "klaus.stammerjohann@fraam.de";
      team_drive = drive_id;
    };

  # add `--dry-run` to test the command
  genJob = drive_name: drive_id: ''
    rclone dedupe --dedupe-mode rename "${drive_name}:"
    rclone sync --drive-skip-shortcuts "${drive_name}:" "/tank/enc/fraam-gdrive-backup/${drive_id}"
  '';
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
    jobs.fraam-gdrive-backup = {
      user = "fraam-gdrive-backup";
      group = "fraam-gdrive-backup";
      rwpaths = [ "/tank/enc/fraam-gdrive-backup" ];
      startAt = "*-*-* 05:00:00";
      script = concatStringsSep "\n" (mapAttrsToList genJob fraamCfg.drives);
    };

    # passed via systemd with LoadCredential
    credentials =
      {
        "gdrive-key" = "/var/src/secrets/fraam-gdrive-backup-2dcf90646dee.json";
      };
  };
}
