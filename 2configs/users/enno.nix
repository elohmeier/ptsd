# Keep in mind this config is also used for NixOS containers.

{ config, lib, pkgs, ... }:
with lib;

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
      openssh.authorizedKeys.keys =
        let
          sshPubKeys = import ./ssh-pubkeys.nix;
        in
        sshPubKeys.authorizedKeys_enno;
      passwordFile = "/var/src/secrets/mainUser.passwd";
    };
  };
}
