{ pkgs, ... }:

{
  home.packages = [ pkgs.nixvim-full-aw ];

  home.sessionVariables.EDITOR = "nvim";

  programs.fish.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };
}
