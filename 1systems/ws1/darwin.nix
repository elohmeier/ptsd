{ config, pkgs, ... }:

{
  imports = [ <ptsd/2configs/darwin-base.nix> ];

  users.users.enno.uid = 502;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 1;
  nix.buildCores = 1;
}
