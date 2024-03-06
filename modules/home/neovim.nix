p@{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs;[
    gnumake
    go
    lazygit
    neovim
    nixd
    nodejs_latest
    ripgrep
    zig
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # pkgs.clang
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.gcc ];

  home.sessionVariables.EDITOR = "nvim";
}
