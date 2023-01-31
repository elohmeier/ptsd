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

  github-nvim-theme = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "github-nvim-theme";
    version = "0.0.6";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "v${version}";
      sha256 = "sha256-wLX81wgl4E50mRig9erbLyrxyGbZllFbHFAQ9+v60W4=";
    };
  };

  oil-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "oil.nvim";
    version = "2022-01-08";
    src = pkgs.fetchFromGitHub {
      owner = "stevearc";
      repo = "oil.nvim";
      rev = "e4c411002272d6eed159afdf4cae2e74dc7fc813";
      sha256 = "sha256-KTSPkHwqYX7cXm98ZrmEvCvbqxgqhq5SbxEbmnn2NYE=";
    };
  };

  comment-nvim =  pkgs.vimUtils.buildVimPluginFrom2Nix rec {
    pname = "Comment.nvim";
    version = "2023-01-18";
    src = pkgs.fetchFromGitHub {
      owner = "numToStr";
      repo = "Comment.nvim";
      rev = "eab2c83a0207369900e92783f56990808082eac2";
      sha256 = "sha256-7UtZAE9tPlnpeHS2LLol/LGVOxptDXNKWXHNHvFBNk4=";
    };
  };

  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        coc-nvim
        comment-nvim
        copilot-vim
        editorconfig-nvim
        formatter-nvim
        github-nvim-theme
        gitsigns-nvim
        impatient-nvim
        leap-nvim
        lualine-nvim
        nnn-nvim
        nvim-lspconfig
        nvim-web-devicons
        oil-nvim
        spread-nvim
        telescope-fzf-native-nvim
        telescope-nvim
        trouble-nvim
        vim-fugitive
        vim-repeat # required by leap.nvim

        (nvim-treesitter.withPlugins (plugins: with plugins; [
          tree-sitter-bash
          tree-sitter-beancount
          tree-sitter-c
          tree-sitter-c-sharp
          tree-sitter-cpp
          tree-sitter-css
          tree-sitter-fish
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
          tree-sitter-sql
          tree-sitter-svelte
          tree-sitter-typescript
          tree-sitter-yaml
        ]))
      ];
    };
  };
in
{
  home.file.".config/nvim".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/nvim else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/nvim";
  home.file.".local/share/nvim/site/pack".source = "${pluginPack}/pack";
  home.file.".config/coc/extensions".source = "${pkgs.coc-extensions}";
  home.file.".config/coc/ultisnips".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/snippets else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/snippets";

  home.packages = with pkgs;[
    gopls
    luaformatter
    neovim
    nodejs-slim-16_x # for copilot, NodeJS 18 not yet supported
    pyright
    ripgrep # for telescope
    rnix-lsp
  ];

  home.sessionVariables.EDITOR = "nvim";
}
