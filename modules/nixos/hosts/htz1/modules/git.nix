_:

{
  services.gitolite = {
    enable = true;
    adminPubkey = (import ../../../users/ssh-pubkeys.nix).sshPub.enno_yubi41;
    group = "git";
    user = "git";
  };
}
