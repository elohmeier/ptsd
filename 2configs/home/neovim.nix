p@{ config, lib, pkgs, ... }:

let
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
    version = "0.0.7";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "v${version}";
      sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
    };
  };

  jupyter_ascending = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "jupyter_ascending.vim";
    version = "2023-01-22";
    src = pkgs.fetchFromGitHub {
      owner = "untitled-ai";
      repo = "jupyter_ascending.vim";
      rev = "8b0f533fbf7f48d12feddedc10b78c53afa41bc2";
      sha256 = "sha256-7KvGXklm53h8tUeVPeeXt30SyV9VrVp+NlPJH9aPr2A=";
    };
  };

  pluginPack = pkgs.vimUtils.packDir {
    mypack = {
      start = with pkgs.vimPlugins; [
        coc-nvim
        comment-nvim
        copilot-vim
        editorconfig-nvim
        github-nvim-theme
        gitsigns-nvim
        impatient-nvim
        indent-blankline-nvim
        jupyter_ascending
        leap-nvim
        lualine-nvim
        neo-tree-nvim
        nvim-dap
        nvim-dap-python
        nvim-dap-ui
        nvim-dap-virtual-text
        nvim-jdtls
        nvim-lspconfig
        nvim-treesitter-textobjects
        nvim-web-devicons
        oil-nvim
        spread-nvim
        telescope-fzf-native-nvim
        which-key-nvim
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
          tree-sitter-jsonnet
          tree-sitter-lua
          tree-sitter-markdown
          tree-sitter-nix
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
  home.file = {
    ".config/nvim".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/nvim else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/nvim";
    ".local/share/nvim/site/pack".source = "${pluginPack}/pack";
    ".config/coc/ultisnips".source = if (builtins.hasAttr "nixosConfig" p) then ../../src/snippets else config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/repos/ptsd/src/snippets";
  } // lib.optionalAttrs (pkgs.stdenv.isDarwin) {
    ".config/coc/extensions".source = "${pkgs.coc-extensions}";
  };

  home.packages = with pkgs;[
    efm-langserver
    gopls
    luaformatter
    nil
    neovim-nightly
    pyright
    ripgrep # for telescope
  ];

  home.sessionVariables.EDITOR = "nvim";
}
