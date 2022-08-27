{ config, lib, pkgs, ... }:

{
  services.borgbackup.jobs.rpi4 = {
    compression = "zstd,3";
    encryption = { mode = "repokey-blake2"; passCommand = "cat /var/src/secrets/nwbackup.borgkey"; };
    environment.BORG_RSH = "ssh -i /var/src/secrets/nwbackup.id_ed25519";
    postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName";
    repo = "ssh://borg-${config.networking.hostName}@rpi4.pug-coho.ts.net/./";
  };
}
