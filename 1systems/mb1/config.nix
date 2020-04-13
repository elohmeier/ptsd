{ config, pkgs, ... }:

let
  vims = pkgs.callPackage <ptsd/2configs/vims.nix> {};
in
{
  imports = [
    <ptsd/2configs/darwin>
  ];

  environment.systemPackages = [
    vims.small
  ];

  ptsd.nwbackup = {
    enable = true;
  };

  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 1;
  nix.buildCores = 1;
}
