{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.git;
    userName = "Enno Lohmeier";
    userEmail = "enno@nerdworks.de";
    signing = {
      key = "0x807BC3355DA0F069";
      signByDefault = false;
    };
    ignores = [ "*~" "*.swp" ".ipynb_checkpoints/" ".vscode/" ];
    extraConfig = {
      pull = {
        rebase = false;
        ff = "only";
      };
    };
  };
}
