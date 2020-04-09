{ config, pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  home-manager.users.enno = { pkgs, ... }: {
    imports = [ ./home.nix ];
  };

  users.users.enno = {
    createHome = true;
    description = "Enno Lohmeier";
    home = "/Users/enno";
    isHidden = false;
    shell = "${pkgs.zsh}/bin/zsh";
    uid = 501;
  };

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };



  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 1;
  nix.buildCores = 1;
}
