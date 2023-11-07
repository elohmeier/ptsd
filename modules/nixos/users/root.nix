{ config, lib, pkgs, ... }:

{
  users.users = {
    root = {
      openssh.authorizedKeys.keys =
        let
          sshPubKeys = import ./ssh-pubkeys.nix;
        in
        sshPubKeys.authorizedKeys_enno;

      # make sure the /var/src fs is marked for early mounting with
      # neededForBoot = true
      hashedPasswordFile = lib.mkIf config.ptsd.secrets.enable (lib.mkDefault "/var/src/secrets/root.passwd");
    } // lib.optionalAttrs config.programs.fish.enable {
      shell = pkgs.fish;
    };
  };
}
