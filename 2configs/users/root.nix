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
      passwordFile = lib.mkIf config.ptsd.secrets.enable "/var/src/secrets/root.passwd";
    };
  };

  #  home-manager.users.root = { pkgs, lib, ... }:
  #  {
  #  home.stateVersion = lib.mkDefault "20.09";

  #      imports = [
  #        ../home/fish.nix
  #        ../home/neovim.nix
  #        ../home/tmux.nix
  #      ];
  #    };

}
