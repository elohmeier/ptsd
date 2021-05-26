{ ... }:

let
  repo = "ssh://u267169-sub1@u267169.your-storagebox.de:23/./borg";
  passCmd = "cat /var/src/secrets/nwbackup.borgkey";
in
{

  environment.variables = {
    BORG_BASE_DIR = "/var/lib/borg";
    BORG_REPO = repo;
    BORG_PASSCOMMAND = passCmd;
  };

  services.borgbackup.jobs.hetzner = {
    paths = [ "/tank/enc" "/var/lib" ];
    exclude = [ "/var/lib/borg" "/tank/enc/roms" ];
    repo = repo;
    environment = {
      BORG_BASE_DIR = "/var/lib/borg";
    };
    readWritePaths = [ "/var/lib/borg" ];
    encryption = {
      mode = "repokey";
      passCommand = passCmd;
    };
    compression = "auto,lzma,6";
    doInit = false;
    extraCreateArgs = "--stats --exclude-caches";
    prune.keep = {
      within = "1d"; # Keep all archives from the last day
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };

  systemd.services.borgbackup-job-hetzner.serviceConfig.StateDirectory = "borg";
}
