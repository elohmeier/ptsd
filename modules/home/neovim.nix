p@{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs;[
    go
    lazygit
    neovim
    nixd
    nodejs_latest
    ripgrep
    zig
  ];

  home.sessionVariables.EDITOR = "nvim";
}
