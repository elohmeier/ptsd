p@{ config, lib, pkgs, pkgsUnstable, ... }:

{
  home.packages = [
    pkgs.gnumake
    pkgs.go
    pkgsUnstable.neovim
    pkgs.nixd
    pkgs.nodejs_latest
    pkgs.ripgrep
    pkgs.zig
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # pkgs.clang
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.gcc ];

  home.sessionVariables.EDITOR = "nvim";
}
