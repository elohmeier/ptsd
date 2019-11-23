{ config, lib, pkgs, ... }:

let
  sshPubKeys = import ./ssh-pubkeys.nix;
in
{

  environment.shellAliases = import ./aliases.nix;

  users = {
    mutableUsers = false;

    users.root = {
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        sshPubKeys.sshPub.nw1
        sshPubKeys.sshPub.nw15_terminus
        sshPubKeys.sshPub.nw30
        sshPubKeys.sshPub.enno_yubi41
        sshPubKeys.sshPub.enno_yubi49
      ];
    };
  };

  # pubkeys
  # hostkeys
  # timezone
  # ssh
  # ...

}
