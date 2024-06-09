{ pkgsUnstable, ... }:

{
  home.packages = [
    pkgsUnstable.nixvim-full
  ];

  home.sessionVariables.EDITOR = "nvim";
}
