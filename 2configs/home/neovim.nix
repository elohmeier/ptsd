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
    version = "1.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "v${version}";
      sha256 = "sha256-30+5q6qE1GCetNKdUC15LcJeat5e0wj9XtNwGdpRsgk=";
    };
  };

  notebook-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "notebook.nvim";
    version = "2023-05-11";
    src = pkgs.fetchFromGitHub {
      owner = "meatballs";
      repo = "notebook.nvim";
      rev = "e7145d5e905f74ac927aa45fe109adbdd9e9f340";
      sha256 = "sha256-jNQqnRgxb3Ta9VKSfEW6bXDIGeo7LQXdwOERiAawSkk=";
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
        leap-nvim
        lualine-nvim
        neo-tree-nvim
        notebook-nvim
        nvim-dap
        nvim-dap-python
        nvim-dap-ui
        nvim-dap-virtual-text
        nvim-jdtls
        nvim-lspconfig
        nvim-spectre
        nvim-surround
        nvim-treesitter-textobjects
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
          tree-sitter-dart
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
  };

  home.packages = with pkgs;[
    efm-langserver
    gopls
    luaformatter
    nil
    neovim
    # neovim-nightly
    pyright
    ripgrep # for telescope
    nodejs-18_x
    nixpkgs-fmt
  ];

  home.sessionVariables.EDITOR = "nvim";
}
