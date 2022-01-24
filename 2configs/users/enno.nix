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
        [
          "wheel"
          "networkmanager"
          "libvirtd"
          "docker"
          "syncthing"
          "video"
          "dialout"
          "input" # useful for dosbox on tty
          "vboxusers"
        ];
      openssh.authorizedKeys.keys =
        let
          sshPubKeys = import ./ssh-pubkeys.nix;
        in
        sshPubKeys.authorizedKeys_enno;
      passwordFile = lib.mkIf config.ptsd.secrets.enable "/var/src/secrets/mainUser.passwd";
    };
  };
}
