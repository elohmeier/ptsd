p@{ config, lib, pkgs, ... }:

let
  nnn-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nnn-nvim";
    version = "2022-08-23";
    src = pkgs.fetchFromGitHub {
      owner = "luukvbaal";
      repo = "nnn.nvim";
      rev = "f9a4584085d37844c23874d916bc3934c6beabf0";
      sha256 = "sha256-qjGieRXdf50Jo447WkIa2uHJqORW0jHtqXo8IFxkEhA=";
    };
  };

  copilot-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "copilot.vim";
    version = "1.5.3";
    src = pkgs.fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "1bfbaf5b027ee4d3d3dbc828c8bfaef2c45d132d";
      sha256 = "sha256-hm/8q08aIVWc5thh31OVpVoksVrqKD+rSHbUTxzzHaU=";
    };
    meta.homepage = "https://github.com/github/copilot.vim/";
  };

  spread-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "spread.nvim";
    version = "2022-08-24";
    src = pkgs.fetchFromGitHub {
      owner = "aarondiel";
      repo = "spread.nvim";
      rev = "95d85a4bdca2a602bd2d3e2f240da6719df842f1";
      sha256 = "sha256-ObuzgxE+Tp7ftQNsWVvfPtp8JP1pvG5qUylXKH+JlhM=";
    };
  };

  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        cmp-buffer
        cmp-nvim-lsp
        cmp-path
        cmp_luasnip
        copilot-vim
        editorconfig-nvim
        formatter-nvim
        hop-nvim
        lualine-nvim
        luasnip
        nnn-nvim
        nvim-cmp
        nvim-lspconfig
        nvim-web-devicons
        spread-nvim
        telescope-fzf-native-nvim
        telescope-nvim

        (nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-bash
          tree-sitter-beancount
          tree-sitter-c
          tree-sitter-c-sharp
          tree-sitter-cpp
          tree-sitter-css
          tree-sitter-go
          tree-sitter-html
          tree-sitter-java
          tree-sitter-json
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-nix
          tree-sitter-norg
          tree-sitter-php
          tree-sitter-python
          tree-sitter-rust
          # tree-sitter-sql  # not in 22.05 yet
          tree-sitter-typescript
          tree-sitter-yaml
        ]))
      ];
    };
  };
in
{
  # package & EDITOR env are configured in ../nwhost-mini.nix

  home.file.".config/nvim".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/nvim else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/nvim";
  home.file.".local/share/nvim/site/pack".source = "${pluginPack}/pack";

  home.packages = with pkgs;[
    gopls
    luaformatter
    nodejs # for copilot
    pyright
    ripgrep # for telescope
    rnix-lsp
  ];

  home.sessionVariables.EDITOR = "nvim";
}
