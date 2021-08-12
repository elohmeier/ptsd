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
        [ "wheel" "networkmanager" "libvirtd" "docker" "syncthing" "video" "dialout" ];
      openssh.authorizedKeys.keys =
        let
          sshPubKeys = import ./ssh-pubkeys.nix;
        in
        sshPubKeys.authorizedKeys_enno;
      passwordFile = "/var/src/secrets/mainUser.passwd";
    };
  };

  home-manager.users.mainUser = { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        package = pkgs.git;
        userName = "Enno Richter";
        userEmail = "enno@nerdworks.de";
        signing = {
          key = "0x807BC3355DA0F069";
          signByDefault = false;
        };
        ignores = [ "*~" "*.swp" ".ipynb_checkpoints/" ];
        extraConfig = {
          init.defaultBranch = "master";
          pull = {
            rebase = false;
            ff = "only";
          };
        };
        delta = {
          enable = true;
          options = {
            decorations = {
              commit-decoration-style = "bold yellow box ul";
              file-decoration-style = "none";
              file-style = "bold yellow ul";
            };
            features = "decorations";
            whitespace-error-style = "22 reverse";
            #paging = "never";
          };
        };
      };
    };
}
