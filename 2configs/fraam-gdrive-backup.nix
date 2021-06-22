{ config, pkgs, lib, ... }:

with lib;
let
  drives = {
    f0_0alle = "0AA26e69F5QmkUk9PVA";
    f0_1kunden = "0AC6ZHnKv2QgsUk9PVA";
    f0_2marketing = "0API2f7f812TbUk9PVA";
    f0_3sales = "0ABuTKy4kgUvKUk9PVA";
    f0_5finance = "0AAy4pJoetOnlUk9PVA";
    f0_6hr = "0ADrdMKsB9cNWUk9PVA";
    f0_7gf = "0ANOBnn3tPOGyUk9PVA";
    f0_8buchhaltung = "0ABEuXStk9pwbUk9PVA";
    f1_6hr = "0AAUVUGDIeZd5Uk9PVA";
    f1_7gf = "0AC-Exw0cveuoUk9PVA";
    f1_8buchhaltung = "0AIbNE9Cop2hNUk9PVA";
    f2_6hr = "0AAPTrKVYVUpbUk9PVA";
    f2_7gf = "0AEAQaHzWdOu4Uk9PVA";
    f2_8buchhaltung = "0ABOFjHaAxmIOUk9PVA";
    f3_6hr = "0ANj3HPYZAFUXUk9PVA";
    f3_7gf = "0AK7ne7Z2WHsoUk9PVA";
  };

  genCfg = drive_name: drive_id: nameValuePair
    drive_name
    {
      type = "drive";
      client_id = "100812309064118189865";
      scope = "drive.readonly";
      service_account_file = "$CREDENTIALS_DIRECTORY/gdrive-key";
      impersonate = "enno.richter@fraam.de";
      team_drive = drive_id;
    };

  genJob = drive_name: drive_id: nameValuePair
    drive_name
    {
      # add `--dry-run` to test the command
      cmd = "sync ${drive_name}: /tank/enc/fraam-gdrive-backup/${drive_name}";
      groups = [ "fraam-gdrive-backup" ];
      rwpaths = [ "/tank/enc/fraam-gdrive-backup" ];
      startAt = "*-*-* 05:00:00";
    };
in
{
  users.groups.fraam-gdrive-backup = { };

  ptsd.rclone = {
    config = mapAttrs' genCfg drives;
    jobs = mapAttrs' genJob drives;

    credentials =
      {
        "gdrive-key" = "/var/src/secrets/fraam-gdrive-backup-3b42c04ff1ec.json";
      };
  };
}
