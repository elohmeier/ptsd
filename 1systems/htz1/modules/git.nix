{ config, lib, pkgs, ... }:

{
  services.gitolite = {
    enable = true;
    adminPubkey = (import ../../../2configs/users/ssh-pubkeys.nix).sshPub.enno_yubi41;
    group = "git";
    user = "git";
  };

  # users.users.git = {
  #   createHome = false;
  #   description = "Git repo personal access (non-shared)";
  #   group = "git";
  #   home = "/var/lib/gitea/repositories";
  #   isSystemUser = true;
  #   openssh.authorizedKeys.keys = (import ../../../2configs/users/ssh-pubkeys.nix).git_enno;
  #   shell = "${pkgs.git}/bin/git-shell"; # prevent interactive login
  # };

  # users.groups.git = { };
}
