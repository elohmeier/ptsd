{ pkgs, ... }:

{
  home.packages = [ pkgs.nixvim-full ];

  home.sessionVariables.EDITOR = "nvim";

  programs.fish.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
