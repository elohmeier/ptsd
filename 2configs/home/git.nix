{ config, pkgs, ... }:

{

  programs.git = {
    enable = true;
    userName = "Enno Lohmeier";
    userEmail = "enno@nerdworks.de";
    signing = {
      key = "0x807BC3355DA0F069";
      signByDefault = false;
    };
    ignores = [ "*~" "*.swp" ".ipynb_checkpoints/" ];
  };
}
