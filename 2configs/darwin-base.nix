{ config, pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  home-manager.users.enno = { pkgs, ... }: {
    imports = [ ./darwin-home.nix ];
  };

  users.users.enno = {
    createHome = true;
    description = "Enno Lohmeier";
    home = "/Users/enno";
    isHidden = false;
    shell = "${pkgs.zsh}/bin/zsh";
  };

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
