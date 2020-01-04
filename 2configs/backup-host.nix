{ config, lib, pkgs, ... }:

with lib;

let
  variables = import <ptsd/2configs/ssh-pubkeys.nix>;
  repos = {

    mb1 = {
      authorizedKeysAppendOnly = [ variables.sshPub.mb1 ];
      path = "/mnt/backup/nw1/borg";
      quota = "250G";
      user = "borg-mb1";
    };

    nuc1 = {
      authorizedKeys = [ variables.sshPub.nuc1_root ];
      authorizedKeysAppendOnly = [ variables.sshPub.nuc1_root ];
      path = "/mnt/backup/nw10/borg";
      quota = "500G";
      user = "borg-nuc1";
    };

    apu1 = {
      authorizedKeysAppendOnly = [ variables.sshPub.apu1_root ];
      path = "/mnt/backup/nw11/borg";
      quota = "10G";
      user = "borg-apu1";
    };

    eee1 = {
      authorizedKeysAppendOnly = [ variables.sshPub.eee1_root ];
      path = "/mnt/backup/eee1/borg";
      quota = "1G";
      user = "borg-eee1";
    };

    tp2 = {
      authorizedKeysAppendOnly = [ variables.sshPub.tp2 ];
      path = "/mnt/backup/nw23/borg";
      quota = "80G";
      user = "borg-nw23"; # fix on Luisas Laptop first
    };

    tp1 = {
      authorizedKeysAppendOnly = [ variables.sshPub.tp1_root ];
      path = "/mnt/backup/nw30/borg";
      quota = "30G";
      user = "borg-tp1";
    };

    htz1 = {
      authorizedKeysAppendOnly = [ variables.sshPub.htz1_root ];
      path = "/mnt/backup/nw32/borg";
      quota = "10G";
      user = "borg-htz1";
    };

    # DLRG APU
    apu2 = {
      authorizedKeysAppendOnly = [ variables.sshPub.apu2_root ];
      path = "/mnt/backup/nw34/borg";
      quota = "2G";
      user = "borg-apu2";
    };

    # DLRG RPi Uwe
    rpi2 = {
      authorizedKeysAppendOnly = [ variables.sshPub.rpi2_root ];
      path = "/mnt/backup/nw35/borg";
      quota = "2G";
      user = "borg-nw35"; # fix on rpi first
    };

    ws1 = {
      authorizedKeysAppendOnly = [ variables.sshPub.ws1_root ];
      path = "/mnt/backup/ws1/borg";
      quota = "50G";
      user = "borg-ws1";
    };
  };

  init-backup-device = pkgs.init-backup-device.override { repos = repos; };

  monitrc_borg_fs = lib.concatMapStrings (
    name: ''
      check filesystem borg-${name} with path /mnt/backup/${name}
        if space usage > 90% then alert
        if inode usage > 90% then alert
      
    ''
  ) [
    "eee1"
    "nw1"
    "nw10"
    "nw11"
    "nw23"
    "nw30"
    "nw32"
    "nw34"
    "nw35"
    "ws1"
  ];
in
{
  imports = [
    <ptsd/3modules>
  ];

  environment.systemPackages = [ init-backup-device ];

  services.borgbackup.repos = repos;

  systemd.services.borgbackup-repo-eee1.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw1.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw10.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw11.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw23.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw30.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw32.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw34.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-nw35.wantedBy = pkgs.lib.mkForce [];
  systemd.services.borgbackup-repo-ws1.wantedBy = pkgs.lib.mkForce [];

  ptsd.nwmonit.extraConfig = [ monitrc_borg_fs ];

  system.activationScripts.chown-borg-repos = let
    script = ''
      ${lib.concatMapStrings (x: "\nchown -R ${x.user}:borg ${x.path}") (attrValues repos)}
    '';
  in
    stringAfter [ "users" "groups" ] "source ${pkgs.writeText "chown-borg-repos.sh" script}";

}
