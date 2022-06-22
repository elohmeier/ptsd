{ config, lib, pkgs, ... }:

{
  services.gitolite = {
    enable = true;
    adminPubkey = (import ../../../2configs/users/ssh-pubkeys.nix).sshPub.enno_yubi41;
    group = "git";
    user = "git";
  };
}
