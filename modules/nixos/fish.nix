{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      l = "eza -al";
      la = "eza -al";
      lg = "eza -al --git";
      ll = "eza -l";
      ls = "eza";
      tree = "eza --tree";
    };
  };

  users.defaultUserShell = pkgs.fish;

  environment.systemPackages = [ pkgs.eza ];
}
