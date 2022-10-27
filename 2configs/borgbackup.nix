{ config, lib, pkgs, ... }:

let
  host2sub = host: {
    htz1 = "sub4";
    htz2 = "sub5";
    htz3 = "sub6";
    rpi4 = "sub7";
  }.${host};
  hostName = config.networking.hostName;
  secrets = if hostName == "rpi4" then "/mnt/syncthing" else "/var/src/secrets";
in
{
  services.borgbackup.jobs.hetzner = {
    compression = "zstd,3";
    encryption = { mode = "repokey-blake2"; passCommand = "cat ${secrets}/nwbackup.borgkey"; };
    environment.BORG_RSH = "ssh -i ${secrets}/nwbackup.id_ed25519";
    postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName hetzner"; # curl is called in 5pkgs/default.nix
    repo = "ssh://u267169-${host2sub hostName}@u267169.your-storagebox.de:23/./borg";
  };

  services.borgbackup.jobs.rpi4 = lib.mkIf (config.networking.hostName != "rpi4") {
    compression = "zstd,3";
    encryption = { mode = "repokey-blake2"; passCommand = "cat ${secrets}/nwbackup.borgkey"; };
    environment.BORG_RSH = "ssh -i ${secrets}/nwbackup.id_ed25519";
    postCreate = "${pkgs.borg2prom}/bin/borg2prom $archiveName rpi4"; # curl is called in 5pkgs/default.nix
    repo = "ssh://borg-${hostName}@rpi4.pug-coho.ts.net/./";
  };
}
