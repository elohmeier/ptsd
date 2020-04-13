{ config, pkgs, ... }:

{
  imports = [
    <ptsd/2configs/darwin>
    <ptsd/2configs/darwin-base.nix>
  ];

  networking.hostName = "ws1-osx";

  home-manager.users.enno = { pkgs, ... }: {
    imports = [ <ptsd/2configs/darwin-home.nix> ];
  };

  users.users.enno.uid = 502;

  ptsd.nwbackup = {
    enable = true;
    passCommand = "cat /Users/enno/nwbackup.borgkey";
    paths = [
      "/Users"
      "/Volumes/OSXData" # Photos
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # You should generally set this to the total number of logical cores in your system.
  # $ sysctl -n hw.ncpu
  nix.maxJobs = 1;
  nix.buildCores = 1;
}
