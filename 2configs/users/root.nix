{ ... }:

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
      passwordFile = "/var/src/secrets/root.passwd";
    };
  };

  home-manager.users.mainUser = { pkgs, ... }:
    {
      imports = [
        ../home/fish.nix
        ../home/neovim.nix
        ../home/tmux.nix
      ];
    };
}
