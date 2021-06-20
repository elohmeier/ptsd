# Keep in mind this config is also used for NixOS containers.

{ config, lib, pkgs, ... }:
with lib;
let
  sshPubKeys = import ./ssh-pubkeys.nix;
  authorizedKeys = [
    sshPubKeys.sshPub.ipd1_terminus
    sshPubKeys.sshPub.iph1_terminus
    sshPubKeys.sshPub.iph3_terminus
    sshPubKeys.sshPub.enno_yubi41
    sshPubKeys.sshPub.enno_yubi49
  ];
in
{
  users.users = {
    mainUser = {
      name = "enno";
      isNormalUser = true;
      home = "/home/enno";
      createHome = true;
      useDefaultShell = true;
      uid = 1000;
      description = "Enno Richter";
      extraGroups =
        [ "wheel" "networkmanager" "libvirtd" "docker" "syncthing" "video" "dialout" ];
      openssh.authorizedKeys.keys = authorizedKeys;
      passwordFile = "/var/src/secrets/mainUser.passwd";
    };
  };
}
