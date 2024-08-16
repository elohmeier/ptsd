# Keep in mind this config is also used for NixOS containers.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users = {
    mainUser = {
      name = "gordon";
      isNormalUser = lib.mkDefault true;
      home = lib.mkDefault "/home/gordon";
      createHome = true;
      uid = lib.mkDefault 1000;
      description = lib.mkDefault "Gordon Shumway";
      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "docker"
        "syncthing"
        "video"
        "dialout"
        "input" # useful for dosbox on tty
        "vboxusers"
        "tss"
      ];
      openssh.authorizedKeys.keys =
        let
          sshPubKeys = import ./ssh-pubkeys.nix;
        in
        sshPubKeys.authorizedKeys_enno;
      hashedPasswordFile = "/nix/secrets/mainUser.passwd";
    } // lib.optionalAttrs config.programs.fish.enable { shell = pkgs.fish; };
  };
}
