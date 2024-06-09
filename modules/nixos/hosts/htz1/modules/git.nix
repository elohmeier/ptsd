_:

{
  services.gitolite = {
    enable = true;
    adminPubkey = (import ../../../users/ssh-pubkeys.nix).sshPub.enno_yubi41;
    group = "git";
    user = "git";
  };

  services.openssh.settings.Macs = [
    # defaults
    "hmac-sha2-512-etm@openssh.com"
    "hmac-sha2-256-etm@openssh.com"
    "umac-128-etm@openssh.com"

    # added for passforios
    "hmac-sha2-512"
  ];
}
