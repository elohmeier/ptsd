{ config, pkgs, lib, ... }:

{
  users.groups.fraam-gdrive-backup = { };

  ptsd.rclone = {
    config = {
      f0_0alle = {
        type = "drive";
        client_id = "100812309064118189865";
        scope = "drive.readonly";
        service_account_file = "$CREDENTIALS_DIRECTORY/gdrive-key";
        impersonate = "enno.richter@fraam.de";
        team_drive = "0AA26e69F5QmkUk9PVA";
      };
    };

    credentials =
      {
        "gdrive-key" = "/var/src/secrets/fraam-gdrive-backup-3b42c04ff1ec.json";
      };

    jobs = {
      f0_0alle = {
        # add `--dry-run` to test the command
        cmd = "sync --max-size 100M f0_0alle: /tank/enc/fraam-gdrive-backup/f0_0alle";
        groups = [ "fraam-gdrive-backup" ];
        rwpaths = [ "/tank/enc/fraam-gdrive-backup" ];
        startAt = "*-*-* 05:00:00";
      };
    };
  };
}
