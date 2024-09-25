{ pkgs, ... }:

{
  home.packages = [ pkgs.nixvim-full ];

  home.sessionVariables.EDITOR = "nvim";
}
